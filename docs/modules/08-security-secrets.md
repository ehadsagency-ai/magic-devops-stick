# Module 8: Sécurité & Gestion des Secrets

Dans notre parcours DevOps, nous avons automatisé la construction, le déploiement et la surveillance de nos applications. Mais avons-nous pensé à la sécurité ? La sécurité n'est pas une étape finale, mais une pratique continue qui doit être intégrée à chaque phase du cycle de vie du logiciel. C'est le principe du **DevSecOps**.

Ce module se concentre sur deux aspects critiques : la sécurisation de nos conteneurs et de notre infrastructure, et la gestion des données sensibles (secrets) de manière sécurisée.

## 1. La Sécurité dans le Cycle de Vie DevOps

L'approche "Shift Left" en sécurité consiste à déplacer les pratiques de sécurité le plus tôt possible dans le cycle de développement. Au lieu d'attendre un audit de sécurité juste avant la mise en production, on intègre la sécurité dès la phase de codage.

| Phase DevOps | Pratique de Sécurité Associée |
| :--- | :--- |
| **Planification** | Modélisation des menaces (Threat Modeling) |
| **Codage** | Analyse de composition des logiciels (SCA) pour les dépendances, analyse statique du code (SAST) |
| **Build** | Scan des images de conteneurs à la recherche de vulnérabilités |
| **Test** | Analyse dynamique du code (DAST), tests de pénétration automatisés |
| **Déploiement** | Scan de la configuration IaC, validation des politiques de sécurité |
| **Opération** | Monitoring de la sécurité, détection d'intrusions, gestion des patchs |

## 2. Sécurisation des Conteneurs Docker

Les conteneurs offrent une isolation, mais ils ne sont pas une solution magique. Voici quelques bonnes pratiques pour sécuriser vos images et vos conteneurs.

- **Utiliser des Images de Base Minimalistes**: Préférez des images comme `alpine` ou `slim`. Moins il y a de paquets, moins il y a de surface d'attaque.
- **Ne pas Exécuter en tant que `root`**: C'est l'une des règles les plus importantes. Créez un utilisateur non-privilégié dans votre `Dockerfile` et utilisez l'instruction `USER` pour l'activer.
  ```dockerfile
  RUN addgroup -S appgroup && adduser -S appuser -G appgroup
  USER appuser
  ```
- **Scanner les Images**: Utilisez des outils comme **Trivy**, **Clair** ou **Snyk** pour scanner vos images Docker à la recherche de vulnérabilités connues (CVEs) dans vos paquets système et vos dépendances applicatives. Cette étape doit être intégrée à votre pipeline CI/CD.
- **Utiliser des Builds Multi-Stage**: Ne laissez pas les outils de compilation (compilateurs, SDK, etc.) dans votre image finale. Utilisez un premier stage pour compiler votre application, puis copiez uniquement l'artefact binaire dans une image de production minimaliste.

## 3. Sécurité dans Kubernetes

Kubernetes offre de nombreux mécanismes pour renforcer la sécurité de vos déploiements.

- **RBAC (Role-Based Access Control)**: Le principe du moindre privilège. Ne donnez aux utilisateurs et aux services que les permissions dont ils ont strictement besoin. Définissez des `Roles` (pour un namespace) ou des `ClusterRoles` (pour tout le cluster) et liez-les à des `ServiceAccounts` via des `RoleBindings`.
- **Pod Security Policies / Pod Security Admission**: Définissez des politiques qui empêchent, par exemple, le lancement de conteneurs privilégiés ou l'exécution en tant que root.
- **Network Policies**: Agissent comme un pare-feu au sein du cluster. Par défaut, tous les Pods peuvent communiquer entre eux. Les `NetworkPolicies` vous permettent de définir des règles précises sur qui peut parler à qui (ex: "seuls les Pods avec le label `frontend` peuvent parler au Pod `backend` sur le port 8080").
- **Secrets Kubernetes**: Kubernetes fournit un objet `Secret` pour stocker des données sensibles. Cependant, par défaut, ils sont simplement encodés en base64 (ce qui n'est pas du chiffrement) et stockés dans `etcd`. Il est crucial d'activer le chiffrement des secrets au repos dans `etcd`.

## 4. Le Problème de la Gestion des Secrets

Où stocker les mots de passe de base de données, les clés d'API, les certificats TLS ?

- **NE PAS les stocker en clair dans le code ou dans Git.** C'est la pire des pratiques.
- **Les variables d'environnement ?** C'est mieux, mais elles peuvent fuiter dans les logs ou être inspectées par d'autres processus sur la machine.
- **Les Secrets Kubernetes ?** C'est une bonne première étape, mais la gestion (rotation, audit) peut être complexe, et la sécurité par défaut est limitée.

Pour une gestion robuste, centralisée et sécurisée, on utilise un **gestionnaire de secrets** dédié.

## 5. HashiCorp Vault : Le Coffre-Fort Central

**Vault** est un outil open source de HashiCorp qui fournit une gestion centralisée des secrets. Il est conçu pour gérer tous les types de secrets dans les environnements cloud modernes.

**Fonctionnalités Clés de Vault**:
- **Stockage Sécurisé**: Les secrets sont chiffrés au repos.
- **Accès Dynamique aux Secrets**: Au lieu de stocker des mots de passe de base de données à longue durée de vie, Vault peut générer des identifiants de base de données à la volée avec une durée de vie limitée (TTL). Une fois le TTL expiré, les identifiants sont automatiquement révoqués.
- **Chiffrement en tant que Service**: Vault peut chiffrer/déchiffrer des données pour vos applications sans avoir à stocker les clés de chiffrement dans l'application elle-même.
- **Authentification Forte**: Les applications et les utilisateurs doivent s'authentifier auprès de Vault (via des tokens, des certificats, des intégrations cloud comme AWS IAM, etc.) avant de pouvoir accéder aux secrets.
- **Audit Détaillé**: Chaque action dans Vault est enregistrée dans un journal d'audit, vous permettant de savoir qui a accédé à quoi et quand.

Dans un environnement Kubernetes, une application peut s'authentifier auprès de Vault en utilisant son `ServiceAccount`, puis récupérer les secrets dont elle a besoin de manière dynamique au démarrage.

## Exercices

Il est temps de mettre un cadenas sur votre infrastructure. Rendez-vous dans le répertoire `../exercises/advanced/` et suivez les instructions du fichier `08-security-exercises.md`. Vous apprendrez à scanner une image Docker, à appliquer des politiques de sécurité dans Kubernetes, et à configurer Vault pour gérer les secrets de votre application.

La sécurité est un voyage, pas une destination. En intégrant ces pratiques dans votre routine DevOps, vous construisez des systèmes non seulement efficaces, mais aussi résilients face aux menaces.
