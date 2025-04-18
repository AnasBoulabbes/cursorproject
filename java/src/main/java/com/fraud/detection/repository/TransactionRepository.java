package com.fraud.detection.repository;

import com.fraud.detection.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByCardNumber(String cardNumber);
    List<Transaction> findByStatus(String status);
} 