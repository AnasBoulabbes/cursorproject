-- Insertion des règles de détection de fraude de base
INSERT INTO fraud_rules (rule_id, rule_name, rule_description, rule_condition, severity_level, is_active, created_at)
VALUES (1, 'High Amount Transaction', 'Transaction avec un montant anormalement élevé', 'amount > 1000', 3, 1, SYSTIMESTAMP);

INSERT INTO fraud_rules (rule_id, rule_name, rule_description, rule_condition, severity_level, is_active, created_at)
VALUES (2, 'Multiple Transactions', 'Plusieurs transactions en peu de temps', 'count > 5 in 24h', 4, 1, SYSTIMESTAMP);

INSERT INTO fraud_rules (rule_id, rule_name, rule_description, rule_condition, severity_level, is_active, created_at)
VALUES (3, 'Unusual Location', 'Transaction depuis un lieu inhabituel', 'location not in common_locations', 2, 1, SYSTIMESTAMP);

INSERT INTO fraud_rules (rule_id, rule_name, rule_description, rule_condition, severity_level, is_active, created_at)
VALUES (4, 'Unusual Merchant', 'Transaction avec un marchand inhabituel', 'merchant_id not in common_merchants', 2, 1, SYSTIMESTAMP);

INSERT INTO fraud_rules (rule_id, rule_name, rule_description, rule_condition, severity_level, is_active, created_at)
VALUES (5, 'High Risk Combination', 'Combinaison de plusieurs facteurs de risque', 'risk_score > 50', 5, 1, SYSTIMESTAMP);

COMMIT; 