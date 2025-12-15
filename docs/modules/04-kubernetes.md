# Module 4: Orchestration avec Kubernetes

Vous savez maintenant comment empaqueter une application dans un conteneur Docker. C'est une étape essentielle. Mais que se passe-t-il lorsque votre application devient populaire et que vous devez exécuter des dizaines, voire des centaines, de conteneurs ? Comment les mettez-vous à jour sans interruption de service ? Comment assurez-vous qu'un conteneur qui plante est automatiquement redémarré ?

C'est là qu'intervient l'**orchestration de conteneurs**, et **Kubernetes** (souvent abrégé en **K8s**) est le leader incontesté dans ce domaine. Il prend vos conteneurs et leur donne des super-pouvoirs pour fonctionner à grande échelle en production.

## 1. Pourquoi l'Orchestration ?

Docker est excellent pour gérer des conteneurs sur une seule machine. Kubernetes, lui, est conçu pour gérer des conteneurs sur un **cluster** de machines (nœuds). Il automatise les tâches opérationnelles complexes :

- **Déploiement et Mise à l'échelle (Scaling)**: Augmentez ou diminuez le nombre de conteneurs en fonction de la charge.
- **Auto-réparation (Self-healing)**: Redémarre automatiquement les conteneurs qui échouent, remplace les nœuds défectueux.
- **Découverte de Services et Équilibrage de Charge (Service Discovery & Load Balancing)**: Expose vos conteneurs sur le réseau et répartit le trafic entre eux.
- **Déploiements et Mises à Jour Automatisés**: Mettez à jour vos applications sans temps d'arrêt (rolling updates).
- **Gestion de la Configuration et des Secrets**: Gérez les informations de configuration et les données sensibles de manière sécurisée.

## 2. L'Architecture de Kubernetes

Imaginez un cluster Kubernetes comme un navire. Il y a le poste de commandement (le **Control Plane**) et l'équipage qui fait le travail (les **Worker Nodes**).

- **Control Plane (Master Nodes)**: C'est le cerveau du cluster. Il prend les décisions : où placer les conteneurs, comment répondre à une défaillance, etc. Ses composants principaux sont :
    - **API Server**: La porte d'entrée du cluster. Toutes les communications passent par lui.
    - **etcd**: La base de données fiable du cluster, qui stocke l'état de tout.
    - **Scheduler**: Décide sur quel Worker Node un nouveau conteneur doit être exécuté.
    - **Controller Manager**: S'assure que l'état réel du cluster correspond à l'état désiré.

- **Worker Nodes**: Ce sont les machines (physiques ou virtuelles) qui exécutent vos conteneurs. Chaque Worker Node exécute deux services principaux :
    - **Kubelet**: L'agent qui communique avec le Control Plane et s'assure que les conteneurs sont en cours d'exécution sur son nœud.
    - **Kube-proxy**: Gère la mise en réseau sur le nœud.

Vous, en tant qu'utilisateur, interagissez principalement avec l'API Server via l'outil en ligne de commande `kubectl`.

## 3. Les Objets Fondamentaux de Kubernetes

Dans Kubernetes, tout est un **objet**. Vous décrivez l'état souhaité de votre application en utilisant ces objets, et Kubernetes se charge de le réaliser.

| Objet | Description |
| :--- | :--- |
| **Pod** | La plus petite unité déployable dans Kubernetes. C'est une enveloppe autour d'un ou plusieurs conteneurs qui partagent le même réseau et le même stockage. En général, un Pod contient un seul conteneur principal. |
| **Deployment** | Un objet qui gère un ensemble de Pods identiques (replicas). Il vous permet de décrire l'état souhaité (ex: "je veux 3 instances de mon application web") et gère les mises à jour (rolling updates) et l'auto-réparation. **C'est l'objet que vous utiliserez le plus souvent pour déployer vos applications.** |
| **Service** | Fournit une adresse réseau stable pour un ensemble de Pods. Comme les Pods peuvent être créés et détruits, leur adresse IP change. Un Service agit comme un point d'accès fixe et un équilibreur de charge pour ces Pods. |
| **ConfigMap** | Permet de découpler les données de configuration de vos images de conteneurs. Vous pouvez stocker des variables d'environnement ou des fichiers de configuration dans un ConfigMap et les monter dans vos Pods. |
| **Secret** | Similaire à un ConfigMap, mais destiné aux données sensibles comme les mots de passe, les tokens d'API, ou les certificats TLS. Les données sont stockées de manière plus sécurisée (encodées en base64, et potentiellement chiffrées au repos). |
| **Namespace** | Permet de créer des espaces de travail virtuels au sein d'un même cluster physique. C'est un moyen d'organiser et d'isoler les ressources (par exemple, un namespace pour l'équipe de développement, un pour l'équipe de test). |

## 4. L'Approche Déclarative : Le YAML

Avec Docker, vous utilisiez souvent des commandes impératives (`docker run ...`). Avec Kubernetes, l'approche est **déclarative**. Vous n'expliquez pas *comment* faire quelque chose, mais *ce que* vous voulez obtenir. Vous écrivez l'état souhaité dans des fichiers **YAML**.

Voici un exemple simple pour un Deployment et un Service :

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mon-app-deployment
spec:
  replicas: 3 # On veut 3 instances de notre Pod
  selector:
    matchLabels:
      app: mon-app
  template:
    metadata:
      labels:
        app: mon-app
    spec:
      containers:
      - name: mon-app-conteneur
        image: mon-app-web:1.0 # L'image Docker à utiliser
        ports:
        - containerPort: 80
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-app-service
spec:
  selector:
    app: mon-app # Ce service cible les Pods avec ce label
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer # Expose le service à l'extérieur du cluster
```

Pour appliquer cette configuration au cluster, vous utilisez une seule commande :

```bash
kubectl apply -f deployment.yaml -f service.yaml
```

Kubernetes lit ces fichiers et travaille en coulisses pour que la réalité corresponde à votre déclaration.

## 5. Interagir avec `kubectl`

`kubectl` est votre couteau suisse pour parler à votre cluster Kubernetes.

| Commande | Description |
| :--- | :--- |
| `kubectl apply -f <fichier.yaml>` | Applique une configuration déclarative au cluster. |
| `kubectl get <objet>` | Liste les objets (ex: `kubectl get pods`, `kubectl get services`). |
| `kubectl describe <objet> <nom>` | Affiche des informations détaillées sur un objet spécifique. Très utile pour le débogage. |
| `kubectl logs <nom_pod>` | Affiche les logs d'un Pod. |
| `kubectl exec -it <nom_pod> -- /bin/bash` | Ouvre un shell interactif à l'intérieur d'un Pod. |

## 6. Kubernetes en Local

Grâce au Magic DevOps Stick, vous n'avez pas besoin d'un compte cloud pour commencer. Des outils comme **Kind** (Kubernetes in Docker) ou **Minikube** vous permettent de créer un cluster Kubernetes complet sur votre machine locale en quelques minutes. Le script d'installation a déjà configuré ces outils pour vous.

Pour créer un cluster local avec Kind :

```bash
kind create cluster --name devops-training
```

## Exercices

Il est temps de déployer votre première application sur Kubernetes ! Rendez-vous dans le répertoire `../exercises/intermediate/` et suivez les instructions du fichier `04-kubernetes-exercises.md`.

Félicitations ! Vous avez fait un grand pas, passant de la gestion d'un seul conteneur à l'orchestration d'une application complète et résiliente. Cette compétence est l'une des plus recherchées dans l'industrie aujourd'hui.
