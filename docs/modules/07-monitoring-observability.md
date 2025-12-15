# Module 7: Monitoring & Observabilité

Déployer une application en production, c'est bien. Savoir ce qui s'y passe en temps réel, c'est mieux. Le monitoring et l'observabilité sont les disciplines qui vous permettent de comprendre la santé et le comportement de vos systèmes. Sans eux, vous naviguez à l'aveugle.

Ce module vous apprendra à collecter des données, à les visualiser et à mettre en place des alertes pour détecter les problèmes avant même que vos utilisateurs ne s'en aperçoivent.

## 1. Monitoring vs. Observabilité

Bien que souvent utilisés de manière interchangeable, ces deux concepts sont différents mais complémentaires.

- **Monitoring (Surveillance)**: C'est le processus qui consiste à collecter et à analyser des données sur un système pour surveiller sa santé. Vous définissez à l'avance ce que vous voulez surveiller (ex: l'utilisation du CPU, la mémoire disponible). C'est répondre à des questions que vous savez déjà que vous allez poser.

- **Observabilité**: C'est la capacité de poser des questions arbitraires sur votre système sans avoir à définir à l'avance ce que vous voulez savoir. L'observabilité est une propriété du système lui-même, qui doit exposer suffisamment de données pour être "observable".

Un système observable est un système que vous pouvez comprendre de l'extérieur, simplement en observant les signaux qu'il émet.

## 2. Les Trois Piliers de l'Observabilité

L'observabilité repose sur trois types de données télémétriques principaux.

| Pilier | Description | Cas d'usage |
| :--- | :--- | :--- |
| **Métriques (Metrics)** | Des mesures numériques collectées à intervalles réguliers (ex: utilisation CPU, nombre de requêtes par seconde, latence). Elles sont excellentes pour les tableaux de bord et les alertes. | "L'utilisation du CPU a-t-elle dépassé 80% ?" |
| **Logs (Journaux)** | Des enregistrements d'événements horodatés. Ils fournissent un contexte détaillé sur ce qui s'est passé à un moment précis. | "Quelle était l'erreur exacte qui a provoqué le plantage de l'application à 14h32 ?" |
| **Traces (Distributed Tracing)** | Suivent le parcours d'une seule requête à travers plusieurs services dans une architecture microservices. Essentiel pour identifier les goulots d'étranglement. | "Pourquoi la requête de l'utilisateur X a-t-elle pris 3 secondes ? Quel service a été le plus lent ?" |

## 3. La Stack de Monitoring Populaire : Prometheus & Grafana

Une combinaison d'outils open source est devenue un standard de l'industrie pour le monitoring basé sur les métriques.

### Prometheus

**Prometheus** est une base de données de séries temporelles (time-series database) et un système de monitoring. Son modèle est basé sur le **pull** : Prometheus contacte périodiquement des "cibles" (vos applications, vos serveurs) sur un endpoint HTTP (généralement `/metrics`) pour récupérer les métriques actuelles.

**Concepts Clés de Prometheus**:
- **Time Series**: Un flux de valeurs horodatées appartenant à la même métrique et au même ensemble de labels.
- **Labels**: Des paires clé-valeur qui permettent de dimensionner les métriques (ex: `http_requests_total{method="POST", path="/api/users"}`).
- **PromQL**: Le langage de requête puissant de Prometheus pour interroger et agréger les données.
- **Alertmanager**: Un composant qui gère les alertes déclenchées par Prometheus (dédoublonnage, regroupement, envoi vers Slack, PagerDuty, etc.).

### Grafana

**Grafana** est un outil de visualisation. Il se connecte à différentes sources de données (dont Prometheus, mais aussi des bases de données SQL, Elasticsearch, etc.) et vous permet de créer des tableaux de bord (dashboards) riches et interactifs.

Avec Grafana, vous pouvez transformer les données brutes de Prometheus en graphiques significatifs qui vous donnent un aperçu instantané de la santé de votre système.

## 4. Gestion Centralisée des Logs avec la Stack ELK (ou EFK)

Lorsque vous avez des dizaines de conteneurs qui génèrent des logs, il est impossible de se connecter à chacun d'eux. Vous avez besoin d'un système centralisé pour agréger, stocker et rechercher ces logs.

La **Stack ELK** est une solution populaire pour cela :

- **Elasticsearch**: Un moteur de recherche et d'analyse distribué. C'est là que les logs sont stockés et indexés.
- **Logstash**: Un pipeline de traitement de données côté serveur. Il ingère les données de multiples sources, les transforme, puis les envoie vers une destination comme Elasticsearch.
- **Kibana**: L'interface web de visualisation et d'exploration pour les données stockées dans Elasticsearch.

Une alternative courante est la **Stack EFK**, où **Fluentd** remplace Logstash. Fluentd est plus léger et est souvent préféré dans les environnements conteneurisés.

## 5. Mise en Place du Monitoring dans Kubernetes

Kubernetes s'intègre parfaitement avec ces outils. Le **Prometheus Operator**, par exemple, simplifie considérablement le déploiement et la gestion de Prometheus dans un cluster K8s. Il peut découvrir automatiquement les services à surveiller grâce aux annotations des objets Kubernetes.

De même, des outils comme Fluentd peuvent être déployés en tant que **DaemonSet** (un Pod par nœud) pour collecter automatiquement les logs de tous les conteneurs du cluster et les envoyer à Elasticsearch.

## Exercices

Il est temps de mettre en place votre propre système de surveillance. Rendez-vous dans le répertoire `../exercises/intermediate/` et suivez les instructions du fichier `07-monitoring-exercises.md`. Vous déploierez Prometheus et Grafana pour surveiller un cluster Kubernetes, et vous configurerez une stack de logging centralisée.

Savoir ce qui se passe dans vos systèmes est la première étape pour les rendre fiables et performants. Dans le prochain module, nous aborderons un autre aspect crucial : la sécurité.
