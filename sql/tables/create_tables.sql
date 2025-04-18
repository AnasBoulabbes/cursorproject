-- Création des tables pour le système de détection de fraudes

-- Table des transactions
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    card_number VARCHAR2(16) NOT NULL,
    merchant_id VARCHAR2(20) NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    currency VARCHAR2(3) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    location VARCHAR2(100),
    status VARCHAR2(20) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Table des règles de détection
CREATE TABLE fraud_rules (
    rule_id NUMBER PRIMARY KEY,
    rule_name VARCHAR2(100) NOT NULL,
    rule_description VARCHAR2(500),
    rule_condition CLOB NOT NULL,
    severity_level NUMBER(1) NOT NULL,
    is_active NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP
);

-- Table des alertes de fraude
CREATE TABLE fraud_alerts (
    alert_id NUMBER PRIMARY KEY,
    transaction_id NUMBER NOT NULL,
    rule_id NUMBER NOT NULL,
    alert_status VARCHAR2(20) NOT NULL,
    alert_description VARCHAR2(500),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (rule_id) REFERENCES fraud_rules(rule_id)
);

-- Table des profils de clients
CREATE TABLE customer_profiles (
    customer_id NUMBER PRIMARY KEY,
    card_number VARCHAR2(16) NOT NULL,
    avg_transaction_amount NUMBER(10,2),
    max_transaction_amount NUMBER(10,2),
    common_locations VARCHAR2(1000),
    risk_score NUMBER(3),
    last_updated TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Création des séquences
CREATE SEQUENCE transaction_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE rule_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE alert_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;

-- Création des index
CREATE INDEX idx_transactions_card ON transactions(card_number);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_alerts_status ON fraud_alerts(alert_status);
CREATE INDEX idx_customer_card ON customer_profiles(card_number); 