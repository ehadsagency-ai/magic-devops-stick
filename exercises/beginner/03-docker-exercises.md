# Exercices - Module 3: Conteneurisation avec Docker

Dans ce module, vous allez mettre en pratique les concepts de Docker en créant vos propres images et en exécutant des conteneurs. Ces exercices progressent de la simple exécution d'une image existante à la création de vos propres images.

## Exercice 1: Exécuter Votre Premier Conteneur

**Objectif**: Comprendre comment exécuter un conteneur à partir d'une image existante.

1.  Téléchargez et exécutez l'image officielle `hello-world` :
    ```bash
    docker run hello-world
    ```
    Vous devriez voir un message de bienvenue.

2.  Exécutez une image Ubuntu et explorez son système de fichiers :
    ```bash
    docker run -it ubuntu:22.04 /bin/bash
    ```
    À l'intérieur du conteneur, exécutez quelques commandes :
    ```bash
    cat /etc/os-release
    ls -la /
    exit
    ```

3.  Listez tous les conteneurs (y compris les arrêtés) :
    ```bash
    docker ps -a
    ```

**Validation**: Vous devriez voir les conteneurs que vous avez exécutés dans la liste.

## Exercice 2: Gérer les Conteneurs

**Objectif**: Apprendre à démarrer, arrêter et supprimer des conteneurs.

1.  Exécutez un conteneur Nginx en arrière-plan :
    ```bash
    docker run -d --name my-nginx -p 8080:80 nginx:latest
    ```

2.  Vérifiez que le conteneur est en cours d'exécution :
    ```bash
    docker ps
    ```

3.  Accédez à Nginx dans votre navigateur ou via curl :
    ```bash
    curl http://localhost:8080
    ```

4.  Consultez les logs du conteneur :
    ```bash
    docker logs my-nginx
    ```

5.  Arrêtez le conteneur :
    ```bash
    docker stop my-nginx
    ```

6.  Vérifiez qu'il est arrêté :
    ```bash
    docker ps
    ```

7.  Redémarrez le conteneur :
    ```bash
    docker start my-nginx
    ```

8.  Supprimez le conteneur :
    ```bash
    docker stop my-nginx
    docker rm my-nginx
    ```

**Validation**: Vous devriez être capable de gérer le cycle de vie complet d'un conteneur.

## Exercice 3: Créer Votre Première Image Docker

**Objectif**: Créer une image Docker personnalisée en utilisant un `Dockerfile`.

1.  Créez un répertoire pour votre projet :
    ```bash
    mkdir my-docker-app
    cd my-docker-app
    ```

2.  Créez un fichier `Dockerfile` simple :
    ```dockerfile
    FROM python:3.11-slim
    
    WORKDIR /app
    
    RUN echo "#!/usr/bin/env python3" > app.py && \
        echo "print('Hello from Docker!')" >> app.py
    
    CMD ["python", "app.py"]
    ```

3.  Construisez l'image :
    ```bash
    docker build -t my-hello-app:1.0 .
    ```

4.  Exécutez un conteneur à partir de votre image :
    ```bash
    docker run my-hello-app:1.0
    ```

5.  Listez vos images :
    ```bash
    docker images
    ```

**Validation**: Vous devriez voir votre image dans la liste et le conteneur devrait afficher "Hello from Docker!".

## Exercice 4: Créer une Image pour une Application Web

**Objectif**: Créer une image Docker pour une application web réelle.

1.  Naviguez vers le répertoire de l'exemple d'application :
    ```bash
    cd /path/to/magic-devops-stick/examples/docker-examples/simple-web-app
    ```

2.  Construisez l'image :
    ```bash
    docker build -t devops-web-app:1.0 .
    ```

3.  Exécutez un conteneur :
    ```bash
    docker run -d --name my-web-app -p 8000:8000 devops-web-app:1.0
    ```

4.  Testez l'application :
    ```bash
    curl http://localhost:8000
    curl http://localhost:8000/health
    curl http://localhost:8000/api/info
    ```

5.  Consultez les logs :
    ```bash
    docker logs -f my-web-app
    ```

6.  Arrêtez et supprimez le conteneur :
    ```bash
    docker stop my-web-app
    docker rm my-web-app
    ```

**Validation**: L'application devrait répondre aux requêtes HTTP avec des réponses JSON.

## Exercice 5: Utiliser Docker Compose

**Objectif**: Orchestrer plusieurs conteneurs avec Docker Compose.

1.  Créez un fichier `docker-compose.yml` :
    ```yaml
    version: '3.8'
    
    services:
      web:
        image: devops-web-app:1.0
        ports:
          - "8000:8000"
        environment:
          - ENVIRONMENT=production
      
      redis:
        image: redis:7-alpine
        ports:
          - "6379:6379"
    ```

2.  Démarrez la stack :
    ```bash
    docker-compose up -d
    ```

3.  Vérifiez que les services sont en cours d'exécution :
    ```bash
    docker-compose ps
    ```

4.  Testez la connectivité entre les services :
    ```bash
    docker-compose exec web curl http://redis:6379
    ```

5.  Consultez les logs :
    ```bash
    docker-compose logs -f
    ```

6.  Arrêtez la stack :
    ```bash
    docker-compose down
    ```

**Validation**: Les deux services devraient être en cours d'exécution et communiquer entre eux.

## Défi Bonus: Créer une Image Multi-Stage

**Objectif**: Optimiser la taille de l'image en utilisant des builds multi-stage.

Modifiez le `Dockerfile` de l'application web pour utiliser une approche multi-stage :
- Stage 1 : Compiler/préparer l'application
- Stage 2 : Créer l'image finale avec uniquement les artefacts nécessaires

**Indice**: Utilisez deux instructions `FROM` dans le même `Dockerfile`.

## Conclusion

Vous avez maintenant les compétences pour créer, gérer et orchestrer des conteneurs Docker. Ces compétences sont la base pour le prochain module : l'orchestration à grande échelle avec Kubernetes.
