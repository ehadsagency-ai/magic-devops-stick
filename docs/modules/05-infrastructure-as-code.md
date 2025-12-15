# Module 5: Infrastructure as Code (IaC)

Jusqu'à présent, nous avons appris à empaqueter notre code (Docker) et à l'exécuter à grande échelle (Kubernetes). Mais sur quoi tout cela fonctionne-t-il ? Sur une **infrastructure** : des serveurs, des réseaux, des bases de données, des équilibreurs de charge, etc.

Traditionnellement, cette infrastructure était gérée manuellement, souvent via des interfaces web (on parle de "click-ops") ou des scripts ad-hoc. Cette approche est lente, sujette aux erreurs, et difficile à reproduire. L'**Infrastructure as Code (IaC)** est la pratique qui consiste à gérer et à provisionner l'infrastructure à travers des fichiers de configuration lisibles par l'homme, plutôt que par des outils de configuration manuels.

En d'autres termes, votre infrastructure devient du code. Vous pouvez la versionner avec Git, la soumettre à des revues de code, et l'automatiser complètement.

## 1. Pourquoi l'Infrastructure as Code ?

- **Automatisation**: Élimine les tâches manuelles et répétitives, réduisant les erreurs humaines.
- **Reproductibilité**: Garantit que vous pouvez créer des environnements identiques (développement, test, production) à chaque fois.
- **Rapidité**: Provisionnez des infrastructures complexes en quelques minutes, au lieu de plusieurs heures ou jours.
- **Versioning**: L'historique complet de votre infrastructure est dans Git. Vous savez qui a changé quoi, quand, et pourquoi. Vous pouvez revenir à une version précédente si nécessaire.
- **Collaboration**: Les équipes peuvent travailler ensemble sur des fichiers de configuration, tout comme elles le font pour le code applicatif.

## 2. Deux Catégories d'Outils IaC

Les outils IaC se divisent généralement en deux catégories, qui sont souvent complémentaires.

| Catégorie | Rôle | Exemples d'Outils |
| :--- | :--- | :--- |
| **Outils de Provisioning** | Créent, modifient et détruisent les ressources d'infrastructure de base (serveurs, VPC, bases de données). | **Terraform**, AWS CloudFormation, Azure Resource Manager |
| **Outils de Gestion de Configuration** | Installent et gèrent les logiciels *sur* une infrastructure existante (installer un serveur web, configurer un utilisateur, etc.). | **Ansible**, Puppet, Chef, SaltStack |

Dans ce module, nous allons nous concentrer sur les deux leaders du marché : **Terraform** pour le provisioning et **Ansible** pour la gestion de configuration.

## 3. Provisioning avec Terraform

**Terraform**, développé par HashiCorp, est un outil qui vous permet de définir votre infrastructure de manière déclarative en utilisant un langage appelé HCL (HashiCorp Configuration Language). Il est agnostique vis-à-vis des fournisseurs, ce qui signifie que vous pouvez l'utiliser pour gérer des ressources sur AWS, Azure, Google Cloud, et bien d'autres.

### Concepts Clés de Terraform

- **Providers**: Des plugins qui permettent à Terraform d'interagir avec une API spécifique (ex: le provider AWS, le provider Azure).
- **Resources**: Les blocs de construction de votre infrastructure (ex: une instance EC2, un bucket S3, un réseau virtuel).
- **State File**: Un fichier (souvent `terraform.tfstate`) où Terraform enregistre l'état de l'infrastructure qu'il gère. C'est ainsi qu'il sait ce qu'il a créé et comment le modifier.
- **Variables**: Permettent de paramétrer vos configurations pour les rendre réutilisables.

### Le Workflow Terraform

Le travail avec Terraform suit un cycle simple et puissant :

1.  **`terraform init`**: Initialise le répertoire de travail. Terraform télécharge les providers nécessaires et prépare le backend pour le fichier d'état.
2.  **`terraform plan`**: Compare l'état souhaité (décrit dans vos fichiers `.tf`) à l'état réel (enregistré dans le fichier d'état) et vous montre ce qu'il va créer, modifier ou supprimer. C'est une étape de validation cruciale.
3.  **`terraform apply`**: Applique les changements décrits dans le plan pour faire correspondre l'infrastructure réelle à votre configuration.
4.  **`terraform destroy`**: Détruit toutes les ressources gérées par Terraform.

### Exemple de Code Terraform (HCL)

Voici comment créer une simple instance EC2 sur AWS :

```hcl
# main.tf

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04
  instance_type = "t2.micro"

  tags = {
    Name = "MonWebServer"
  }
}
```

## 4. Gestion de Configuration avec Ansible

Une fois que Terraform a créé un serveur vierge, comment y installer votre application ? C'est le rôle d'**Ansible**. Ansible est un outil de gestion de configuration qui se connecte à vos serveurs (généralement via SSH) et exécute des tâches.

### Concepts Clés d'Ansible

- **Agentless**: Pas besoin d'installer de logiciel client sur les serveurs cibles. Ansible a juste besoin d'un accès SSH et de Python.
- **Inventory**: Un fichier qui liste les serveurs que vous souhaitez gérer.
- **Playbook**: Un fichier YAML qui décrit une série de tâches à exécuter sur un groupe de serveurs.
- **Module**: Une unité de code réutilisable qu'Ansible exécute. Il existe des milliers de modules pour tout faire : gérer des paquets (`apt`, `yum`), des services (`systemd`), des fichiers, etc.

### Exemple de Playbook Ansible

Voici un playbook simple qui installe et démarre le serveur web Nginx sur un groupe de serveurs défini comme `webservers` dans votre inventaire.

```yaml
# playbook.yml
---
- name: Configurer le serveur web
  hosts: webservers
  become: true # Exécuter les tâches avec sudo

  tasks:
    - name: Installer Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Démarrer et activer le service Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

Pour exécuter ce playbook :

```bash
ansible-playbook -i inventory.ini playbook.yml
```

## 5. Le Duo Gagnant : Terraform + Ansible

La combinaison de Terraform et Ansible est extrêmement populaire :

1.  **Terraform** provisionne l'infrastructure de base (VPC, subnets, instances EC2, etc.).
2.  À la fin de son exécution, Terraform peut générer un fichier d'inventaire pour Ansible.
3.  **Ansible** prend le relais, se connecte aux nouvelles instances et les configure (installation de Docker, déploiement de l'application, etc.).

## Exercices

Il est temps de construire votre propre infrastructure ! Rendez-vous dans le répertoire `../exercises/intermediate/` et suivez les instructions du fichier `05-iac-exercises.md` pour provisionner une instance sur un fournisseur de cloud avec Terraform, puis la configurer avec Ansible.

Vous venez de débloquer la capacité de créer et de gérer des environnements complexes de manière entièrement automatisée. C'est une compétence fondamentale pour mettre en œuvre des pipelines CI/CD efficaces, ce que nous verrons dans le prochain module.
