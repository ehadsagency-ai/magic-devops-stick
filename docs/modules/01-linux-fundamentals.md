# Module 1: Fondamentaux Linux & Scripting

Bienvenue dans le premier module du **Magic DevOps Stick** ! La maîtrise de la ligne de commande Linux est une compétence fondamentale pour tout ingénieur DevOps. C'est l'outil que vous utiliserez quotidiennement pour gérer des serveurs, automatiser des tâches, et interagir avec la plupart des outils de l'écosystème DevOps.

Ce module vous guidera à travers les commandes et les concepts essentiels qui constituent la base de votre expertise.

## 1. Le Shell : Votre Interface Principale

Le **shell** est un programme qui interprète vos commandes et les exécute. Le plus courant est **Bash** (`Bourne Again SHell`). Lorsque vous ouvrez un terminal, vous interagissez avec un shell.

- **Prompt**: La ligne qui s'affiche, comme `ubuntu@sandbox:~$`, vous indique qui vous êtes (`ubuntu`), où vous êtes (`sandbox`), et votre répertoire actuel (`~`, qui est le répertoire personnel).
- **Commandes**: Vous tapez une commande (ex: `ls`) et appuyez sur `Entrée` pour l'exécuter.

## 2. Navigation dans le Système de Fichiers

Se déplacer dans l'arborescence des fichiers est une tâche constante.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `pwd` | **Print Working Directory**. Affiche le chemin complet de votre répertoire actuel. | `pwd` |
| `ls` | **List**. Affiche le contenu du répertoire actuel. | `ls -la` (affiche tout, en format long) |
| `cd` | **Change Directory**. Permet de se déplacer vers un autre répertoire. | `cd /var/log` |

**Astuces de navigation**:
- `cd ~` ou `cd`: Retourne à votre répertoire personnel.
- `cd ..`: Remonte d'un niveau dans l'arborescence.
- `cd -`: Retourne au répertoire précédent.

## 3. Manipulation de Fichiers et Répertoires

Créer, déplacer, copier et supprimer des fichiers sont des opérations de base.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `touch` | Crée un fichier vide ou met à jour sa date de modification. | `touch mon_fichier.txt` |
| `mkdir` | **Make Directory**. Crée un nouveau répertoire. | `mkdir mon_repertoire` |
| `cp` | **Copy**. Copie un fichier ou un répertoire. | `cp source.txt destination.txt` |
| `mv` | **Move**. Déplace ou renomme un fichier ou un répertoire. | `mv ancien_nom.txt nouveau_nom.txt` |
| `rm` | **Remove**. Supprime un fichier. | `rm mon_fichier.txt` |
| `rmdir` | **Remove Directory**. Supprime un répertoire vide. | `rmdir mon_repertoire` |
| `rm -r` | Supprime un répertoire et tout son contenu (à utiliser avec précaution !). | `rm -r mon_repertoire` |

## 4. Visualisation du Contenu des Fichiers

Il existe plusieurs façons de lire le contenu d'un fichier sans l'ouvrir dans un éditeur.

| Commande | Description | Exemple |
| :--- | :--- | :--- |
| `cat` | Affiche l'intégralité du contenu d'un fichier dans le terminal. | `cat /etc/os-release` |
| `less` | Affiche le contenu d'un fichier page par page. Très utile pour les longs fichiers. | `less /var/log/syslog` |
| `head` | Affiche les 10 premières lignes d'un fichier. | `head -n 20 mon_fichier.log` |
| `tail` | Affiche les 10 dernières lignes d'un fichier. | `tail -f mon_fichier.log` (suit le fichier en temps réel) |

## 5. Recherche de Fichiers et de Texte

Trouver des informations rapidement est crucial.

- **`find`**: Recherche des fichiers et des répertoires en fonction de critères (nom, taille, date, etc.).
  ```bash
  # Trouver tous les fichiers .md dans le répertoire actuel et ses sous-répertoires
  find . -type f -name "*.md"
  ```

- **`grep`**: Recherche un motif de texte à l'intérieur des fichiers. C'est l'un des outils les plus puissants de la ligne de commande.
  ```bash
  # Chercher le mot "error" dans un fichier de log
  grep "error" /var/log/nginx/error.log
  ```

## 6. Gestion des Permissions

Linux est un système multi-utilisateurs. Les permissions déterminent qui a le droit de lire, écrire ou exécuter un fichier.

- **`chmod`** (Change Mode): Modifie les permissions d'un fichier.
  - Les permissions sont définies pour l'**utilisateur** (u), le **groupe** (g), et les **autres** (o).
  - Les droits sont **lecture** (r=4), **écriture** (w=2), et **exécution** (x=1).

  ```bash
  # Donner les droits d'exécution à l'utilisateur pour un script
  chmod u+x mon_script.sh

  # Attribuer les droits rwx (7) à l'utilisateur, et r-x (5) au groupe et aux autres
  chmod 755 mon_script.sh
  ```

- **`chown`** (Change Owner): Change le propriétaire et/ou le groupe d'un fichier.
  ```bash
  # Changer le propriétaire du fichier pour l'utilisateur "www-data"
  sudo chown www-data:www-data /var/www/html/index.html
  ```

## 7. Introduction au Scripting Shell

Le scripting vous permet d'automatiser des séquences de commandes. Un script shell est simplement un fichier texte contenant des commandes.

Créez un fichier `hello.sh`:

```bash
#!/bin/bash

# Ceci est un commentaire

# Déclarer une variable
NOM="Monde"

# Afficher un message
echo "Bonjour, $NOM !"
```

Pour l'exécuter :

1.  Rendez-le exécutable : `chmod +x hello.sh`
2.  Lancez-le : `./hello.sh`

## Exercices

Maintenant, mettez ces connaissances en pratique ! Rendez-vous dans le répertoire `../exercises/beginner/` et suivez les instructions du fichier `01-linux-exercises.md`.

Félicitations pour avoir terminé ce premier module ! Vous avez maintenant les bases solides pour aborder les outils plus complexes de l'écosystème DevOps.
