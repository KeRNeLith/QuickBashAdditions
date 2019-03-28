# Quick Linux Setup
Ensemble de scripts permettant d'ajouter des commandes bash pratiques.

Commandes
--------

### Bash Modifications

Installation ou mise à jour :

    bash <(curl -Ls https://bit.ly/2U2uVke)

Suppression :

    bash <(curl -Ls https://bit.ly/2HKyPHU)

Juste pour la session actuelle : (Aucun fichier ne va être installé)

    source <(curl -Ls https://bit.ly/2HKzc5g)

Il est possible d'ajouter des nouvelles commandes spécifiques en créant le fichier : .bash_personnal_addition
Dans le répertoire home de l'utilisateur.

### Ubuntu Setup

Installeur Ubuntu16 automatique :

    bash <(curl -Ls https://bit.ly/2HRQ8pL)

OR

    wget -O os-setup.sh https://bit.ly/2HRQ8pL
    chmod 700 os-setup.sh
    ./os-setup.sh -input DIRECTORY

Installeur Ubuntu18 automatique :

    bash <(curl -Ls https://bit.ly/2U2xdQk)

OR

    wget -O os-setup.sh https://bit.ly/2U2xdQk
    chmod 700 os-setup.sh
    ./os-setup.sh -input DIRECTORY