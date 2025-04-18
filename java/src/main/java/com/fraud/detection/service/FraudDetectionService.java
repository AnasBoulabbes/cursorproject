package com.fraud.detection.service;

import com.fraud.detection.model.FraudAlert;
import com.fraud.detection.model.Transaction;
import com.fraud.detection.repository.FraudAlertRepository;
import com.fraud.detection.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class FraudDetectionService {

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private FraudAlertRepository fraudAlertRepository;

    @Transactional
    public BigDecimal analyzeTransaction(Transaction transaction) {
        try {
            // Sauvegarder la transaction (les valeurs par défaut sont définies dans l'entité)
            transaction = transactionRepository.save(transaction);
            System.out.println("Transaction saved with ID: " + transaction.getTransactionId());

            // Appel de la procédure stockée PL/SQL
            StoredProcedureQuery query = entityManager
                .createStoredProcedureQuery("fraud_detection_pkg.analyze_transaction")
                .registerStoredProcedureParameter(1, String.class, ParameterMode.IN)
                .registerStoredProcedureParameter(2, BigDecimal.class, ParameterMode.IN)
                .registerStoredProcedureParameter(3, String.class, ParameterMode.IN)
                .registerStoredProcedureParameter(4, String.class, ParameterMode.IN)
                .registerStoredProcedureParameter(5, BigDecimal.class, ParameterMode.OUT)
                .setParameter(1, transaction.getCardNumber())
                .setParameter(2, transaction.getAmount())
                .setParameter(3, transaction.getMerchantId())
                .setParameter(4, transaction.getLocation());

            // Exécution de la procédure
            query.execute();
            System.out.println("Stored procedure executed");

            // Récupération du résultat
            BigDecimal riskScore = (BigDecimal) query.getOutputParameterValue(5);
            System.out.println("Risk score calculated: " + riskScore);

            // Mise à jour du statut de la transaction
            String newStatus = riskScore.compareTo(new BigDecimal("50")) > 0 ? "SUSPICIOUS" : "APPROVED";
            System.out.println("Transaction status updated to: " + newStatus);
            transaction.setStatus(newStatus);
            transactionRepository.save(transaction);

            return riskScore;
        } catch (Exception e) {
            System.err.println("Error in analyzeTransaction: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Erreur lors de l'analyse de la transaction: " + e.getMessage(), e);
        }
    }

    @Transactional
    public void resolveAlert(Long alertId) {
        FraudAlert alert = fraudAlertRepository.findById(alertId)
            .orElseThrow(() -> new RuntimeException("Alert not found"));
        
        alert.setAlertStatus("RESOLVED");
        alert.setResolvedAt(LocalDateTime.now());
        fraudAlertRepository.save(alert);
    }

    @Transactional(readOnly = true)
    public List<Transaction> getTransactionsByCard(String cardNumber) {
        return transactionRepository.findByCardNumber(cardNumber);
    }

    @Transactional(readOnly = true)
    public List<FraudAlert> getActiveAlerts() {
        return fraudAlertRepository.findByAlertStatus("NEW");
    }
} 