# Guide de Démarrage - Magic DevOps Stick

Bienvenue dans le **Magic DevOps Stick** ! Ce guide présente la structure du projet, les commandes disponibles et le parcours d’apprentissage. Il ne confirme pas qu’une installation a été exécutée sur votre machine.

## 1. Comprendre Votre Nouvel Environnement

Le script d’installation vise à configurer des outils DevOps sur votre machine. Leur disponibilité dépend de l’installation effectivement réalisée ; vérifiez-la avant de lancer les exemples.

Ce dépôt ne garantit pas l’isolation de votre machine. L’installation appelle des commandes avec privilèges d’administration ; travaillez dans une machine virtuelle dédiée ou sur une machine de test avec sauvegarde vérifiée. N’exécutez `scripts/cleanup.sh` qu’après avoir revu ses cibles et ses effets. Aucun mode de nettoyage n’a été testé dans ce contrôle.

## 2. Structure du Projet

Familiarisez-vous avec l'organisation du projet. Voici un aperçu des répertoires les plus importants :

| Répertoire | Contenu |
| :--- | :--- |
| `docs/` | Toute la documentation, y compris les guides pour chaque module de formation. **C'est votre point de départ pour l'apprentissage.** |
| `scripts/` | Les scripts principaux pour l'installation, la validation et le nettoyage de l'environnement. |
| `configs/` | Des fichiers de configuration d'exemple pour Docker, Kubernetes, Terraform, etc. Utilisez-les comme base pour vos propres projets. |
| `examples/` | Des applications et des scénarios complets démontrant l'utilisation des différents outils dans un contexte réel. |
| `exercises/` | Des exercices pratiques pour chaque module, avec des niveaux de difficulté progressifs. |

## 3. Valider Votre Installation

Depuis la racine du dépôt, le script `scripts/validate-setup.sh` permet de contrôler les composants disponibles.

```bash
./scripts/validate-setup.sh
```

Ce script effectue une série de vérifications et fournit un rapport. Si des erreurs apparaissent, consultez la section de dépannage dans `docs/INSTALLATION.md`.

## 4. Votre Premier Module : Fondamentaux Linux

Nous vous recommandons de commencer par le premier module pour vous familiariser avec la ligne de commande, qui est l'outil principal de tout ingénieur DevOps.

1.  **Ouvrez le document du module** :
    ```bash
    less docs/modules/01-linux-fundamentals.md
    ```

2.  **Lisez les concepts** : Le document explique les commandes de base, la gestion des fichiers, les permissions, et le scripting shell.

3.  **Expérimentez avec les exemples** : Testez les commandes directement dans votre terminal.

4.  **Faites les exercices** : Rendez-vous dans le répertoire `exercises/beginner/` et essayez de résoudre les défis proposés.

## 5. Examiner le modèle de stack applicative

Depuis la racine du dépôt, vous pouvez lire le modèle Docker Compose. Il référence `configs/docker/app/`, `configs/docker/prometheus.yml` et un `requirements.txt` dans le contexte de construction, absents de l’arbre suivi. La stack ne peut donc pas être lancée telle quelle.

```bash
less configs/docker/docker-compose.yml
```

## 6. Et Ensuite ?

Votre parcours ne fait que commencer. Voici quelques suggestions pour la suite :

- **Suivez les modules dans l'ordre** : Chaque module s'appuie sur les concepts du précédent.
- **Explorez les exemples** : Le répertoire `examples/` contient des projets plus complexes. Essayez de les déployer et de comprendre leur fonctionnement.
- **Contribuez** : Si vous trouvez des erreurs ou avez des idées d'amélioration, n'hésitez pas à contribuer au projet.

L'apprentissage de DevOps est un marathon, pas un sprint. Prenez votre temps, expérimentez, et surtout, amusez-vous ! Bonne formation !
