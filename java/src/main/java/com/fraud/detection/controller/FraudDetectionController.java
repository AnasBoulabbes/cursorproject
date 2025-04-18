package com.fraud.detection.controller;

import com.fraud.detection.model.FraudAlert;
import com.fraud.detection.model.Transaction;
import com.fraud.detection.service.FraudDetectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/fraud")
public class FraudDetectionController {

    @Autowired
    private FraudDetectionService fraudDetectionService;

    @PostMapping("/analyze")
    public ResponseEntity<BigDecimal> analyzeTransaction(@RequestBody Transaction transaction) {
        BigDecimal riskScore = fraudDetectionService.analyzeTransaction(transaction);
        return ResponseEntity.ok(riskScore);
    }

    @GetMapping("/alerts")
    public ResponseEntity<List<FraudAlert>> getActiveAlerts() {
        List<FraudAlert> alerts = fraudDetectionService.getActiveAlerts();
        return ResponseEntity.ok(alerts);
    }

    @PostMapping("/alerts/{alertId}/resolve")
    public ResponseEntity<Void> resolveAlert(@PathVariable Long alertId) {
        fraudDetectionService.resolveAlert(alertId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/transactions/{cardNumber}")
    public ResponseEntity<List<Transaction>> getTransactionsByCard(@PathVariable String cardNumber) {
        List<Transaction> transactions = fraudDetectionService.getTransactionsByCard(cardNumber);
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/alerts/all")
    public ResponseEntity<List<FraudAlert>> getAllAlerts() {
        List<FraudAlert> alerts = fraudDetectionService.getAllAlerts();
        return ResponseEntity.ok(alerts);
    }
} 