# Guide d'Installation - Magic DevOps Stick

Ce document fournit des instructions détaillées pour l'installation du **Magic DevOps Stick** sur différentes plateformes, ainsi que des conseils de dépannage pour les problèmes courants.

## 1. Prérequis

Avant de commencer, assurez-vous que votre système est à jour et dispose des outils de base suivants. La plupart des systèmes Linux et macOS les incluent par défaut.

```bash
sudo apt-get update && sudo apt-get install -y git curl wget
```

### Configuration Matérielle

- **RAM**: Un minimum de **8 Go** est requis, mais **16 Go ou plus** sont fortement recommandés pour faire fonctionner confortablement des outils comme Kubernetes et la stack ELK.
- **CPU**: Un processeur moderne avec au moins **4 cœurs** est recommandé.
- **Espace Disque**: Prévoyez au moins **20 Go** d'espace disque libre. Les images Docker et les volumes Kubernetes peuvent consommer beaucoup d'espace.

## 2. Processus d'Installation

L'installation est gérée par un script unique qui automatise le téléchargement et la configuration de tous les composants.

### Étape 1: Cloner le Répertoire

Ouvrez un terminal et clonez le projet depuis son dépôt Git.

```bash
git clone https://github.com/your-repo/magic-devops-stick.git
cd magic-devops-stick/scripts
```

### Étape 2: Rendre le Script Exécutable

Assurez-vous que le script d'installation a les permissions d'exécution.

```bash
chmod +x install.sh
```

### Étape 3: Lancer l'Installation

Le script `install.sh` accepte un argument `--mode` pour personnaliser l'installation. Si aucun mode n'est spécifié, le mode `full` est utilisé par défaut.

#### Mode d'Installation Complet (`full`)

Ce mode installe tous les outils et configurations. C'est le mode recommandé pour une expérience d'apprentissage complète.

```bash
sudo ./install.sh --mode full
```

#### Mode d'Installation Modulaire (`modular`)

Ce mode interactif vous permet de choisir les composants à installer. Utilisez-le si vous manquez de ressources ou si vous souhaitez vous concentrer sur des outils spécifiques.

```bash
sudo ./install.sh --mode modular
```

#### Mode d'Installation Léger (`light`)

Ce mode installe uniquement les outils essentiels : Docker, Terraform, et Ansible. Idéal pour les machines avec des ressources limitées.

```bash
sudo ./install.sh --mode light
```

#### Mode d'Installation Cloud (`cloud`)

Ce mode est optimisé pour les environnements cloud (comme une instance EC2). Il installe les outils nécessaires pour interagir avec les fournisseurs de cloud et déployer des infrastructures.

```bash
sudo ./install.sh --mode cloud
```

## 3. Post-Installation

Une fois l'installation terminée, quelques étapes sont nécessaires pour finaliser la configuration de votre environnement.

### Ajout de l'Utilisateur au Groupe Docker

Pour utiliser Docker sans `sudo`, le script tente d'ajouter votre utilisateur au groupe `docker`. Vous devrez peut-être vous déconnecter et vous reconnecter (ou redémarrer votre terminal) pour que ce changement prenne effet.

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Validation de l'Environnement

Exécutez le script de validation pour vous assurer que tout est en ordre.

```bash
./validate-setup.sh
```

## 4. Dépannage

Voici une liste des problèmes courants et de leurs solutions.

| Problème | Solution |
| :--- | :--- |
| **Erreur `permission denied` en utilisant Docker** | Assurez-vous que votre utilisateur fait partie du groupe `docker` et que vous avez redémarré votre session. Vérifiez avec la commande `groups`. |
| **Échec du téléchargement d'un paquet ou d'une image** | Vérifiez votre connexion Internet. Si vous êtes derrière un proxy, assurez-vous que vos variables d'environnement (`HTTP_PROXY`, `HTTPS_PROXY`) sont correctement configurées. |
| **`kubectl` ne peut pas se connecter au cluster** | Si vous utilisez Docker Desktop, assurez-vous que Kubernetes est activé. Si vous utilisez `kind` ou `minikube`, assurez-vous que le cluster est démarré (`kind create cluster` ou `minikube start`). |
| **Espace disque insuffisant** | Le script `cleanup.sh` peut vous aider à libérer de l'espace. Utilisez `docker system prune -a --volumes` pour un nettoyage en profondeur de Docker. |
| **Conflits de ports** | Si un service ne démarre pas en raison d'un conflit de port, modifiez le fichier `docker-compose.yml` pour mapper le service sur un port différent sur votre machine hôte (par exemple, changez `"8080:8080"` en `"8081:8080"`). |

Si vous rencontrez un problème qui n'est pas listé ici, veuillez ouvrir une 
