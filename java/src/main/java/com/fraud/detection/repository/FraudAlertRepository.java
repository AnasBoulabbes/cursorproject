package com.fraud.detection.repository;

import com.fraud.detection.model.FraudAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FraudAlertRepository extends JpaRepository<FraudAlert, Long> {
    List<FraudAlert> findByAlertStatus(String status);
    List<FraudAlert> findByTransaction_TransactionId(Long transactionId);
} 