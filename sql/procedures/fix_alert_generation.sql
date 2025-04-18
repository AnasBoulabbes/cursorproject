CREATE OR REPLACE PACKAGE BODY fraud_detection_pkg AS
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
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END analyze_transaction;
    
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
        COMMIT;
    END generate_alert;
    
    -- ... rest of the package body remains unchanged ...
END fraud_detection_pkg;
/ 