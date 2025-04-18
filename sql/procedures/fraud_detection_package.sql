CREATE OR REPLACE PACKAGE fraud_detection_pkg AS
    -- Procédure pour analyser une nouvelle transaction
    PROCEDURE analyze_transaction(
        p_card_number IN VARCHAR2,
        p_amount IN NUMBER,
        p_merchant_id IN VARCHAR2,
        p_location IN VARCHAR2,
        p_result OUT NUMBER
    );
    
    -- Fonction pour vérifier les transactions multiples
    FUNCTION check_multiple_transactions(
        p_card_number IN VARCHAR2,
        p_time_window IN NUMBER
    ) RETURN NUMBER;
    
    -- Procédure pour mettre à jour le profil client
    PROCEDURE update_customer_profile(
        p_card_number IN VARCHAR2,
        p_amount IN NUMBER,
        p_location IN VARCHAR2
    );
    
    -- Procédure pour générer une alerte
    PROCEDURE generate_alert(
        p_transaction_id IN NUMBER,
        p_rule_id IN NUMBER,
        p_description IN VARCHAR2
    );
END fraud_detection_pkg;
/

CREATE OR REPLACE PACKAGE BODY fraud_detection_pkg AS
    FUNCTION check_multiple_transactions(
        p_card_number IN VARCHAR2,
        p_time_window IN NUMBER
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM transactions
        WHERE card_number = p_card_number
        AND transaction_date >= SYSTIMESTAMP - (p_time_window/24);
        
        RETURN v_count;
    END check_multiple_transactions;
    
    PROCEDURE update_customer_profile(
        p_card_number IN VARCHAR2,
        p_amount IN NUMBER,
        p_location IN VARCHAR2
    ) IS
    BEGIN
        MERGE INTO customer_profiles cp
        USING (SELECT p_card_number as card_number FROM dual) src
        ON (cp.card_number = src.card_number)
        WHEN MATCHED THEN
            UPDATE SET
                avg_transaction_amount = (avg_transaction_amount + p_amount) / 2,
                max_transaction_amount = GREATEST(max_transaction_amount, p_amount),
                common_locations = common_locations || ',' || p_location,
                last_updated = SYSTIMESTAMP
        WHEN NOT MATCHED THEN
            INSERT (customer_id, card_number, avg_transaction_amount, max_transaction_amount, common_locations, risk_score)
            VALUES (customer_seq.NEXTVAL, p_card_number, p_amount, p_amount, p_location, 0);
    END update_customer_profile;
    
    PROCEDURE generate_alert(
        p_transaction_id IN NUMBER,
        p_rule_id IN NUMBER,
        p_description IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO fraud_alerts (
            alert_id,
            transaction_id,
            rule_id,
            alert_status,
            alert_description,
            created_at
        ) VALUES (
            alert_seq.NEXTVAL,
            p_transaction_id,
            p_rule_id,
            'NEW',
            p_description,
            SYSTIMESTAMP
        );
    END generate_alert;
    
    PROCEDURE analyze_transaction(
        p_card_number IN VARCHAR2,
        p_amount IN NUMBER,
        p_merchant_id IN VARCHAR2,
        p_location IN VARCHAR2,
        p_result OUT NUMBER
    ) IS
        v_transaction_id NUMBER;
        v_risk_score NUMBER;
        v_multiple_transactions NUMBER;
    BEGIN
        -- Get the latest transaction ID
        SELECT transaction_seq.CURRVAL INTO v_transaction_id FROM dual;
        
        -- Vérifier les transactions multiples dans les dernières 24 heures
        v_multiple_transactions := check_multiple_transactions(p_card_number, 24);
        
        -- Calculer le score de risque
        v_risk_score := 0;
        
        -- Règle 1: Montant anormalement élevé
        IF p_amount > 1000 THEN
            v_risk_score := v_risk_score + 30;
            -- Generate alert for high amount
            generate_alert(v_transaction_id, 1, 'High amount detected: ' || p_amount);
        END IF;
        
        -- Règle 2: Transactions multiples
        IF v_multiple_transactions > 5 THEN
            v_risk_score := v_risk_score + 40;
            -- Generate alert for multiple transactions
            generate_alert(v_transaction_id, 2, 'Multiple transactions detected: ' || v_multiple_transactions);
        END IF;
        
        -- Mettre à jour le profil client
        update_customer_profile(p_card_number, p_amount, p_location);
        
        -- Générer une alerte si le score total est élevé
        IF v_risk_score > 50 THEN
            generate_alert(v_transaction_id, 5, 'High risk combination detected. Total score: ' || v_risk_score);
        END IF;
        
        p_result := v_risk_score;
    END analyze_transaction;
END fraud_detection_pkg;
/ 