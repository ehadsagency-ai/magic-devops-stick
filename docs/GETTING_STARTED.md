# Guide de Démarrage - Magic DevOps Stick

Bienvenue dans le **Magic DevOps Stick** ! Ce guide est votre point de départ pour explorer l'environnement de formation que vous venez d'installer. Nous allons vous présenter la structure du projet, comment interagir avec les outils installés, et comment aborder votre parcours d'apprentissage.

## 1. Comprendre Votre Nouvel Environnement

Le script d'installation a configuré une suite complète d'outils DevOps sur votre machine. La plupart de ces outils sont soit directement accessibles via la ligne de commande (comme `docker`, `kubectl`, `terraform`), soit disponibles sous forme d'images Docker prêtes à être lancées (comme `jenkins`, `grafana`).

L'objectif est de vous fournir un bac à sable (sandbox) où vous pouvez expérimenter sans risque. N'hésitez pas à modifier les configurations, à lancer les exemples, et à casser des choses. Le script `cleanup.sh` est là pour vous aider à repartir d'un état propre.

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

Avant de plonger dans les modules, il est recommandé de vérifier que tout est correctement installé. Le script `validate-setup.sh` est conçu pour cela.

```bash
cd ../scripts
./validate-setup.sh
```

Ce script effectuera une série de vérifications sur tous les composants installés et vous fournira un rapport détaillé. Si des erreurs (`✗`) apparaissent, consultez la section de dépannage dans le fichier `INSTALLATION.md`.

## 4. Votre Premier Module : Fondamentaux Linux

Nous vous recommandons de commencer par le premier module pour vous familiariser avec la ligne de commande, qui est l'outil principal de tout ingénieur DevOps.

1.  **Ouvrez le document du module** :
    ```bash
    less ../docs/modules/01-linux-fundamentals.md
    ```

2.  **Lisez les concepts** : Le document explique les commandes de base, la gestion des fichiers, les permissions, et le scripting shell.

3.  **Expérimentez avec les exemples** : Testez les commandes directement dans votre terminal.

4.  **Faites les exercices** : Rendez-vous dans le répertoire `exercises/beginner/` et essayez de résoudre les défis proposés.

## 5. Lancer une Stack Applicative Complète

Pour avoir un aperçu de la puissance de l'environnement, vous pouvez lancer une stack applicative complète (application web, base de données, cache) en une seule commande grâce à Docker Compose.

1.  **Naviguez vers le répertoire de configuration Docker** :
    ```bash
    cd ../configs/docker
    ```

2.  **Lancez la stack en arrière-plan** :
    ```bash
    docker-compose up -d
    ```

3.  **Vérifiez que les conteneurs tournent** :
    ```bash
    docker-compose ps
    ```
    Vous devriez voir plusieurs services en cours d'exécution : `web`, `postgres`, `redis`, `prometheus`, `grafana`, etc.

4.  **Accédez aux services** :
    - **Application Web**: [http://localhost:8000](http://localhost:8000)
    - **Grafana**: [http://localhost:3000](http://localhost:3000) (login: admin / pass: admin)
    - **Prometheus**: [http://localhost:9090](http://localhost:9090)
    - **Kibana**: [http://localhost:5601](http://localhost:5601)

5.  **Arrêtez et nettoyez la stack** lorsque vous avez terminé :
    ```bash
    docker-compose down --volumes
    ```

## 6. Et Ensuite ?

Votre parcours ne fait que commencer. Voici quelques suggestions pour la suite :

- **Suivez les modules dans l'ordre** : Chaque module s'appuie sur les concepts du précédent.
- **Explorez les exemples** : Le répertoire `examples/` contient des projets plus complexes. Essayez de les déployer et de comprendre leur fonctionnement.
- **Contribuez** : Si vous trouvez des erreurs ou avez des idées d'amélioration, n'hésitez pas à contribuer au projet.

L'apprentissage de DevOps est un marathon, pas un sprint. Prenez votre temps, expérimentez, et surtout, amusez-vous ! Bonne formation !
