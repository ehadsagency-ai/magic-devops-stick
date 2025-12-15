# Exercices - Module 1: Fondamentaux Linux

Bienvenue dans les exercices pratiques du Module 1 ! Ces exercices vous aideront à consolider vos connaissances en ligne de commande Linux. Chaque exercice est progressif, commençant par les tâches simples et évoluant vers des tâches plus complexes.

## Exercice 1: Navigation et Exploration

**Objectif**: Maîtriser la navigation dans le système de fichiers et l'exploration des répertoires.

1.  Ouvrez un terminal.
2.  Affichez votre répertoire de travail actuel : `pwd`
3.  Listez le contenu de votre répertoire personnel : `ls -la ~`
4.  Naviguez vers le répertoire `/etc` : `cd /etc`
5.  Affichez les 10 premiers fichiers du répertoire `/etc` : `ls | head -10`
6.  Retournez à votre répertoire personnel : `cd ~`

**Validation**: Vous devriez être capable de naviguer entre les répertoires et de lister les fichiers avec différentes options.

## Exercice 2: Création et Manipulation de Fichiers

**Objectif**: Créer, copier, déplacer et supprimer des fichiers.

1.  Créez un répertoire appelé `devops-training` : `mkdir devops-training`
2.  Naviguez dans ce répertoire : `cd devops-training`
3.  Créez trois fichiers vides : `touch file1.txt file2.txt file3.txt`
4.  Listez les fichiers créés : `ls -la`
5.  Copiez `file1.txt` en `file1_backup.txt` : `cp file1.txt file1_backup.txt`
6.  Renommez `file2.txt` en `file2_renamed.txt` : `mv file2.txt file2_renamed.txt`
7.  Supprimez `file3.txt` : `rm file3.txt`
8.  Listez les fichiers restants : `ls -la`

**Validation**: Vous devriez avoir trois fichiers : `file1.txt`, `file1_backup.txt`, et `file2_renamed.txt`.

## Exercice 3: Visualisation du Contenu des Fichiers

**Objectif**: Apprendre à lire et à explorer le contenu des fichiers.

1.  Naviguez vers le répertoire `/etc` : `cd /etc`
2.  Affichez le contenu du fichier `hostname` : `cat hostname`
3.  Affichez le contenu du fichier `os-release` : `cat os-release`
4.  Affichez les 5 premières lignes du fichier `passwd` : `head -n 5 passwd`
5.  Affichez les 5 dernières lignes du fichier `passwd` : `tail -n 5 passwd`
6.  Explorez le fichier `services` avec `less` (appuyez sur `q` pour quitter) : `less services`

**Validation**: Vous devriez être capable de visualiser le contenu des fichiers de différentes manières.

## Exercice 4: Recherche de Fichiers et de Texte

**Objectif**: Utiliser les outils de recherche pour trouver des fichiers et du texte.

1.  Naviguez vers votre répertoire personnel : `cd ~`
2.  Trouvez tous les fichiers `.txt` dans votre répertoire personnel : `find . -name "*.txt"`
3.  Trouvez tous les répertoires nommés `bin` sur le système : `find / -type d -name "bin" 2>/dev/null`
4.  Recherchez le mot "root" dans le fichier `/etc/passwd` : `grep "root" /etc/passwd`
5.  Recherchez tous les fichiers contenant le mot "bash" dans `/etc` : `grep -r "bash" /etc 2>/dev/null | head -5`

**Validation**: Vous devriez être capable de localiser des fichiers et de chercher du texte dans les fichiers.

## Exercice 5: Gestion des Permissions

**Objectif**: Comprendre et modifier les permissions des fichiers.

1.  Naviguez vers votre répertoire `devops-training` : `cd ~/devops-training`
2.  Créez un script simple : `echo '#!/bin/bash' > script.sh && echo 'echo "Hello, DevOps!"' >> script.sh`
3.  Affichez les permissions actuelles : `ls -la script.sh`
4.  Rendez le script exécutable : `chmod +x script.sh`
5.  Vérifiez les permissions mises à jour : `ls -la script.sh`
6.  Exécutez le script : `./script.sh`
7.  Modifiez les permissions pour que seul le propriétaire puisse lire et exécuter : `chmod 500 script.sh`
8.  Vérifiez les permissions : `ls -la script.sh`

**Validation**: Vous devriez être capable de changer les permissions et d'exécuter un script.

## Exercice 6: Introduction au Scripting

**Objectif**: Créer et exécuter un script shell simple.

1.  Créez un fichier appelé `hello_world.sh` : `touch hello_world.sh`
2.  Ouvrez-le avec un éditeur (ex: `nano`, `vi`, ou `cat` avec redirection) :
    ```bash
    cat > hello_world.sh << 'EOF'
    #!/bin/bash
    
    # This is a simple script
    echo "Hello, World!"
    echo "Welcome to DevOps Training"
    
    # Display the current date
    echo "Current date: $(date)"
    EOF
    ```
3.  Rendez-le exécutable : `chmod +x hello_world.sh`
4.  Exécutez-le : `./hello_world.sh`
5.  Modifiez le script pour ajouter une variable :
    ```bash
    cat > hello_world.sh << 'EOF'
    #!/bin/bash
    
    NAME="DevOps Engineer"
    echo "Hello, $NAME!"
    echo "Welcome to the training program"
    EOF
    ```
6.  Exécutez-le à nouveau : `./hello_world.sh`

**Validation**: Vous devriez voir le message d'accueil avec votre nom.

## Défi Bonus: Créer un Script de Sauvegarde

**Objectif**: Combiner plusieurs concepts pour créer un script utile.

Créez un script appelé `backup.sh` qui :
1.  Crée un répertoire appelé `backup` dans votre répertoire personnel.
2.  Copie tous les fichiers `.txt` de votre répertoire `devops-training` vers le répertoire `backup`.
3.  Affiche un message de confirmation.

**Indice**: Utilisez les variables, les commandes `mkdir`, `cp`, et `echo`.

**Solution Exemple**:
```bash
#!/bin/bash

BACKUP_DIR="$HOME/backup"
SOURCE_DIR="$HOME/devops-training"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Copy all .txt files
cp "$SOURCE_DIR"/*.txt "$BACKUP_DIR" 2>/dev/null

# Display confirmation
echo "Backup completed. Files copied to $BACKUP_DIR"
ls -la "$BACKUP_DIR"
```

## Conclusion

Félicitations pour avoir complété ces exercices ! Vous avez maintenant une base solide en ligne de commande Linux. Ces compétences vous seront utiles dans tous les modules suivants du Magic DevOps Stick.

N'hésitez pas à revenir à ces exercices et à les modifier pour explorer davantage les capacités de la ligne de commande.
