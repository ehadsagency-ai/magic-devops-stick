# Module 3: Conteneurisation avec Docker

La conteneurisation a révolutionné la manière dont nous développons, livrons et exécutons les applications. **Docker** est l'outil qui a popularisé cette technologie et en a fait un standard de l'industrie. Dans ce module, vous apprendrez à empaqueter vos applications et leurs dépendances dans des unités standardisées et portables appelées conteneurs.

## 1. Pourquoi des Conteneurs ? Le Problème du "Ça Marche sur ma Machine"

Vous avez probablement déjà entendu cette phrase. Un développeur termine une fonctionnalité, et elle fonctionne parfaitement sur son ordinateur portable. Mais lorsque l'application est déployée sur un serveur de test ou de production, elle plante. Les raisons peuvent être multiples : une version différente de Python, une bibliothèque manquante, une variable d'environnement non définie, etc.

Les conteneurs résolvent ce problème en empaquetant l'application avec **tout ce dont elle a besoin pour fonctionner** : le code, le runtime (ex: Python, Node.js), les bibliothèques système, les variables d'environnement et les fichiers de configuration. Ce paquet, appelé **image de conteneur**, est immuable et portable. Si une image fonctionne sur une machine, elle fonctionnera de la même manière sur n'importe quelle autre machine disposant de Docker.

### Conteneurs vs. Machines Virtuelles (VM)

| Caractéristique | Machine Virtuelle (VM) | Conteneur |
| :--- | :--- | :--- |
| **Isolation** | Au niveau du matériel (hyperviseur) | Au niveau du processus (OS) |
| **Système d'exploitation** | Chaque VM a son propre OS invité complet | Partage le noyau de l'OS hôte |
| **Taille** | Lourde (plusieurs Go) | Léger (quelques Mo à quelques centaines de Mo) |
| **Démarrage** | Lent (plusieurs minutes) | Rapide (quelques secondes ou moins) |
| **Ressources** | Consommation élevée (RAM, CPU) | Consommation faible |

En résumé, les conteneurs sont beaucoup plus légers et plus rapides que les VM, ce qui les rend parfaits pour les architectures microservices et les déploiements rapides.

## 2. Concepts Fondamentaux de Docker

- **Image Docker**: C'est un "modèle" ou une "recette" en lecture seule qui contient les instructions pour créer un conteneur. Une image est construite en couches. Par exemple, une image pour une application Python peut être basée sur une image officielle de Python, à laquelle on ajoute une couche pour les dépendances, puis une couche pour le code de l'application.

- **Conteneur Docker**: C'est une instance en cours d'exécution d'une image. Vous pouvez créer, démarrer, arrêter, déplacer et supprimer des conteneurs. Chaque conteneur est isolé des autres et de la machine hôte.

- **Dockerfile**: C'est un fichier texte qui contient les commandes pour assembler une image. C'est la pierre angulaire de l'automatisation avec Docker.

- **Docker Hub / Registry**: C'est un service de stockage et de distribution d'images Docker. Docker Hub est le registre public par défaut, mais vous pouvez aussi avoir des registres privés.

## 3. Construire sa Première Image avec un `Dockerfile`

Le `Dockerfile` est une recette étape par étape. Voici un exemple simple pour une application web Python (Flask) :

```dockerfile
# 1. Choisir une image de base
FROM python:3.9-slim

# 2. Définir le répertoire de travail dans le conteneur
WORKDIR /app

# 3. Copier les dépendances et les installer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copier le reste du code de l'application
COPY . .

# 5. Exposer le port sur lequel l'application écoute
EXPOSE 5000

# 6. Définir la commande pour lancer l'application
CMD ["python", "app.py"]
```

Pour construire l'image à partir de ce `Dockerfile` :

```bash
docker build -t mon-app-web:1.0 .
```

- `-t mon-app-web:1.0`: Donne un nom (`tag`) à l'image.
- `.`: Indique que le `Dockerfile` se trouve dans le répertoire actuel.

## 4. Gérer les Conteneurs

Une fois l'image construite, vous pouvez l'exécuter.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `docker run` | Crée et démarre un nouveau conteneur à partir d'une image. | `docker run -d -p 8080:5000 mon-app-web:1.0` |
| `docker ps` | Liste les conteneurs en cours d'exécution. | `docker ps -a` (affiche tous les conteneurs, même arrêtés) |
| `docker stop` | Arrête un conteneur en cours d'exécution. | `docker stop <id_conteneur>` |
| `docker rm` | Supprime un conteneur arrêté. | `docker rm <id_conteneur>` |
| `docker logs` | Affiche les logs (la sortie standard) d'un conteneur. | `docker logs -f <id_conteneur>` (suit les logs en direct) |
| `docker exec` | Exécute une commande à l'intérieur d'un conteneur en cours d'exécution. | `docker exec -it <id_conteneur> /bin/bash` (ouvre un shell interactif) |

Dans l'exemple `docker run` ci-dessus :
- `-d`: Mode détaché (le conteneur tourne en arrière-plan).
- `-p 8080:5000`: Mappe le port `8080` de la machine hôte au port `5000` du conteneur.

## 5. Orchestrer avec `docker-compose`

La plupart des applications ne se composent pas d'un seul conteneur. Elles ont besoin d'une base de données, d'un cache, etc. `docker-compose` est un outil qui permet de définir et de gérer des applications multi-conteneurs à l'aide d'un simple fichier YAML.

Voici un exemple de `docker-compose.yml` pour une application web avec une base de données Redis :

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:5000"

  redis:
    image: "redis:alpine"
```

Avec ce fichier, vous pouvez lancer toute la stack avec une seule commande :

```bash
docker-compose up -d
```

Et l'arrêter tout aussi simplement :

```bash
docker-compose down
```

`docker-compose` gère automatiquement le réseau entre les conteneurs, vous permettant de vous connecter de `web` à `redis` en utilisant simplement le nom de service `redis`.

## Exercices

La théorie c'est bien, mais la pratique c'est mieux ! Rendez-vous dans le répertoire `../exercises/beginner/` et suivez les instructions du fichier `03-docker-exercises.md` pour créer vos propres images et lancer des applications conteneurisées.

Vous venez d'acquérir une compétence fondamentale qui vous servira de base pour le prochain module : l'orchestration à grande échelle avec Kubernetes.
