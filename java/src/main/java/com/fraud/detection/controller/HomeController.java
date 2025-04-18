package com.fraud.detection.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "Bienvenue dans le système de détection de fraudes\n" +
               "Endpoints disponibles:\n" +
               "- POST /api/fraud/analyze : Analyser une transaction\n" +
               "- GET /api/fraud/alerts : Obtenir les alertes actives\n" +
               "- POST /api/fraud/alerts/{id}/resolve : Résoudre une alerte\n" +
               "- GET /api/fraud/transactions/{cardNumber} : Obtenir les transactions d'une carte";
    }

    @GetMapping("/health")
    public String healthCheck() {
        return "Le service est opérationnel";
    }
} 