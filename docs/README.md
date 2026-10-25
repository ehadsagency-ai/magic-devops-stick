# Magic DevOps Stick

![DevOps Stick Banner](https://example.com/banner.png)  <!-- Placeholder for a banner image -->

## Introduction

Le **Magic DevOps Stick** est un environnement de formation complet et portable, conçu pour vous guider à travers l'écosystème DevOps moderne. Que vous soyez un débutant curieux ou un professionnel cherchant à approfondir ses compétences, ce projet vous fournit tous les outils, configurations, et exemples pratiques nécessaires pour maîtriser les technologies et les méthodologies qui façonnent l'industrie aujourd'hui.

Notre mission est de rendre l'apprentissage de DevOps accessible, pratique et entièrement automatisé. En une seule commande, transformez votre machine en un laboratoire DevOps complet.

## Fonctionnalités Clés

| Fonctionnalité | Description |
| :--- | :--- |
| **Installation Automatisée** | Un script unique (`install.sh`) configure l'ensemble de l'environnement, avec plusieurs modes d'installation (complet, modulaire, léger, cloud). |
| **Environnement Complet** | Inclut Docker, Kubernetes, Terraform, Ansible, Jenkins, Prometheus, Grafana, Vault, et les CLIs des principaux fournisseurs de cloud. |
| **Apprentissage Progressif** | Dix modules de formation structurés, allant des fondamentaux de Linux aux sujets avancés comme le GitOps et les Service Mesh. |
| **Exemples Pratiques** | Des configurations et des applications réelles pour chaque technologie, prêtes à être déployées et étudiées. |
| **Validation Intégrée** | Un script de validation (`validate-setup.sh`) pour vérifier l'intégrité de votre installation à tout moment. |
| **Documentation Riche** | Chaque module est accompagné d'une documentation détaillée, d'exercices et de guides. |

## Modules de Formation

Le parcours d'apprentissage est divisé en 10 modules conçus pour être suivis de manière séquentielle :

1.  **Fondamentaux Linux & Scripting**: Maîtrisez la ligne de commande.
2.  **Contrôle de Version avec Git**: Collaborez et gérez votre code efficacement.
3.  **Conteneurisation avec Docker**: Empaquetez et isolez vos applications.
4.  **Orchestration avec Kubernetes**: Déployez et gérez des applications à grande échelle.
5.  **Infrastructure as Code (IaC)**: Automatisez votre infrastructure avec Terraform et Ansible.
6.  **Pipelines CI/CD**: Intégrez et déployez en continu avec Jenkins et GitHub Actions.
7.  **Monitoring & Observabilité**: Surveillez vos systèmes avec Prometheus, Grafana et l'ELK Stack.
8.  **Sécurité & Gestion des Secrets**: Sécurisez vos applications et votre infrastructure avec Vault.
9.  **Plateformes Cloud**: Interagissez avec AWS, Azure et GCP.
10. **Sujets Avancés**: Explorez le GitOps, les Service Mesh et les patterns d'architecture avancés.

## Démarrage Rapide

Pour commencer votre aventure DevOps, suivez ces trois étapes simples :

1.  **Clonez le projet** :
    ```bash
    git clone https://github.com/ehadsagency-ai/magic-devops-stick.git
    cd magic-devops-stick
    ```

2.  **Lancez l'installation** :
    Le script appelle `sudo` pour certaines opérations ; exécutez-le depuis votre compte habituel. Son installation complète n’a pas été testée dans ce contrôle.
    ```bash
    ./scripts/install.sh --mode full
    ```

3.  **Consultez le guide de démarrage** :
    Une fois l'installation terminée, commencez par lire le guide de démarrage pour une vue d'ensemble complète.
    ```bash
    less docs/GETTING_STARTED.md
    ```

## Prérequis

Avant de lancer l'installation, assurez-vous que votre système répond aux exigences suivantes :

- **Système d'exploitation**: Linux (Ubuntu 22.04 LTS recommandé), macOS, ou Windows avec WSL2.
- **Ressources matérielles**:
  - **RAM**: 8 Go minimum, 16 Go recommandés.
  - **Espace disque**: 20 Go d'espace libre minimum.
- **Logiciels**: `git`, `curl`, et `wget` doivent être installés.
- **Connectivité**: Une connexion Internet stable est requise pour télécharger les paquets et les images.

## Contribution

Ce projet accueille les contributions de la communauté. Aucun fichier `CONTRIBUTING.md` n’est présent dans l’arbre suivi actuel.

## Licence

Le README racine annonce une licence MIT, mais aucun fichier `LICENSE` n’est présent dans l’arbre suivi actuel.
