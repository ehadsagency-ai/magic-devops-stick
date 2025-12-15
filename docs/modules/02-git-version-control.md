# Module 2: Contrôle de Version avec Git

Après avoir maîtrisé la ligne de commande, l'étape suivante pour tout professionnel de la tech est de savoir gérer l'évolution de son code et de ses configurations. C'est le rôle du contrôle de version, et l'outil roi dans ce domaine est **Git**.

Dans ce module, vous apprendrez à suivre les modifications, à revenir en arrière, à travailler sur plusieurs versions en parallèle et à collaborer avec d'autres personnes de manière structurée.

## 1. Qu'est-ce que le Contrôle de Version ?

Imaginez que vous travaillez sur un fichier de configuration important. Vous faites une modification, puis une autre, et soudain, plus rien ne fonctionne. Comment revenir à la version qui marchait ? Le contrôle de version est un système qui enregistre les changements apportés à un fichier ou à un ensemble de fichiers au fil du temps, afin que vous puissiez rappeler des versions spécifiques plus tard.

**Git** est un système de contrôle de version distribué, ce qui signifie que chaque développeur dispose d'une copie complète de l'historique du projet sur sa machine locale.

## 2. Concepts Fondamentaux de Git

| Concept | Description |
| :--- | :--- |
| **Repository (Dépôt)** | C'est le "dossier" de votre projet tel que Git le voit. Il contient tous vos fichiers ainsi que l'historique complet des modifications. |
| **Commit** | Un "instantané" (snapshot) de votre projet à un moment donné. Chaque commit a un identifiant unique et un message qui décrit les changements. |
| **Staging Area (Zone d'index)** | Une zone intermédiaire où vous préparez les modifications que vous souhaitez inclure dans le prochain commit. Cela vous permet de faire des commits très précis. |
| **Branch (Branche)** | Une ligne de développement indépendante. Vous pouvez créer des branches pour travailler sur de nouvelles fonctionnalités sans affecter la version principale (souvent appelée `main` ou `master`). |

## 3. Le Workflow de Base

Voici le cycle de vie le plus courant pour enregistrer une modification dans Git.

1.  **Initialiser un dépôt** : Pour commencer à suivre un projet, vous devez d'abord initialiser un dépôt Git.
    ```bash
    # Se placer dans le répertoire de votre projet
    cd mon-projet

    # Initialiser le dépôt
    git init
    ```

2.  **Vérifier le statut** : La commande `git status` est votre meilleure amie. Elle vous montre l'état de vos fichiers.
    ```bash
    git status
    ```

3.  **Ajouter des fichiers à la Staging Area** : Avant de faire un commit, vous devez dire à Git quels fichiers vous souhaitez inclure.
    ```bash
    # Ajouter un fichier spécifique
    git add mon_fichier.txt

    # Ajouter tous les fichiers modifiés
    git add .
    ```

4.  **Faire un commit** : Une fois que vos fichiers sont dans la staging area, vous pouvez les enregistrer dans un commit.
    ```bash
    git commit -m "Ajout de la documentation initiale"
    ```
    Le message de commit (`-m`) est crucial. Il doit être clair et concis pour que les autres (et vous-même dans le futur) puissent comprendre ce qui a été fait.

## 4. Les Branches : Travailler en Parallèle

Les branches sont l'une des fonctionnalités les plus puissantes de Git. Elles vous permettent de créer un espace de travail isolé pour développer une nouvelle fonctionnalité ou corriger un bug.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `git branch` | Liste toutes les branches. | `git branch` |
| `git branch <nom>` | Crée une nouvelle branche. | `git branch nouvelle-fonctionnalite` |
| `git checkout <nom>` | Se déplace vers une autre branche. | `git checkout nouvelle-fonctionnalite` |
| `git merge <nom>` | Fusionne la branche spécifiée dans votre branche actuelle. | `git merge nouvelle-fonctionnalite` |

**Workflow avec les branches (Feature Branch Workflow)** :

1.  Assurez-vous d'être sur la branche principale : `git checkout main`
2.  Créez une nouvelle branche pour votre travail : `git branch ma-super-fonctionnalite`
3.  Basculez sur cette nouvelle branche : `git checkout ma-super-fonctionnalite` (ou en une seule commande : `git checkout -b ma-super-fonctionnalite`)
4.  Faites votre travail (ajoutez, modifiez des fichiers) et faites des commits.
5.  Lorsque vous avez terminé, retournez à la branche principale : `git checkout main`
6.  Fusionnez votre travail : `git merge ma-super-fonctionnalite`
7.  Supprimez la branche qui n'est plus nécessaire : `git branch -d ma-super-fonctionnalite`

## 5. Travailler avec des Dépôts Distants

Jusqu'à présent, tout ce que nous avons fait est local. Pour collaborer, vous devez interagir avec un dépôt distant, hébergé sur des plateformes comme **GitHub**, **GitLab** ou **Bitbucket**.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `git clone <url>` | Copie un dépôt distant sur votre machine locale. | `git clone https://github.com/user/repo.git` |
| `git remote -v` | Affiche les dépôts distants configurés. | `git remote -v` |
| `git push` | Envoie vos commits locaux vers le dépôt distant. | `git push origin main` |
| `git pull` | Récupère les changements depuis le dépôt distant et les fusionne. | `git pull origin main` |

- **`origin`** est le nom par défaut donné au dépôt distant depuis lequel vous avez cloné.

## 6. Commandes Utiles

- **`git log`**: Affiche l'historique des commits.
  - `git log --oneline --graph --decorate`: Une vue compacte et visuelle de l'historique.
- **`git diff`**: Montre les différences entre votre répertoire de travail et la staging area, ou entre deux commits.

## Exercices

La meilleure façon d'apprendre Git est de l'utiliser. Rendez-vous dans le répertoire `../exercises/beginner/` et suivez les instructions du fichier `02-git-exercises.md` pour mettre en pratique ces concepts.

Vous avez maintenant les clés pour gérer n'importe quel projet basé sur du texte, du code source aux fichiers de configuration de votre infrastructure. C'est une compétence que vous utiliserez constamment dans votre carrière DevOps.
