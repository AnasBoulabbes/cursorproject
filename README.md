# Moteur de Détection de Fraudes pour Paiements Électroniques

Ce projet implémente un système de détection de fraudes pour les paiements électroniques utilisant PL/SQL et Java.

## Architecture

- **Base de données Oracle** : Stockage des transactions et règles de détection
- **PL/SQL** : Logique de détection des fraudes
- **Java** : Interface utilisateur et traitement des alertes

## Structure du Projet

```
fraud-detection/
├── sql/                    # Scripts PL/SQL
│   ├── tables/            # Création des tables
│   ├── procedures/        # Procédures de détection
│   └── triggers/          # Triggers pour la détection en temps réel
├── java/                  # Application Java
│   ├── src/              # Code source
│   └── lib/              # Dépendances
└── docs/                 # Documentation
```

## Fonctionnalités

- Détection de transactions suspectes en temps réel
- Analyse des patterns de fraude
- Génération d'alertes
- Interface de gestion des règles
- Rapports et statistiques

## Prérequis

- Oracle Database 19c ou supérieur
- Java JDK 11 ou supérieur
- Maven 3.6 ou supérieur 