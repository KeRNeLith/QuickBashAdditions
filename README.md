# Quick Linux Setup
Ensemble de scripts permettant d'ajouter des commandes bash pratiques.

Commandes
--------

### Bash Modifications

Installation ou mise à jour :

    bash <(curl -Ls https://goo.gl/wA12tf)

Suppression :

    bash <(curl -Ls https://goo.gl/9fb5eV)

Juste pour la session actuelle : (Aucun fichier ne va être installé)

    source <(curl -Ls https://goo.gl/XNYlYQ)

Il est possible d'ajouter des nouvelles commandes spécifiques en créant le fichier : .bash_personnal_addition
Dans le répertoire home de l'utilisateur.

### Ubuntu Setup

Installeur Ubuntu automatique :

    bash <(curl -Ls https://goo.gl/duKu1P)

    wget -O os-setup.sh https://goo.gl/duKu1P
    chmod 700 os-setup.sh
    ./os-setup.sh
