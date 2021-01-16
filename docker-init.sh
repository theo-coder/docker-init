#!/bin/bash

# URL du repo contenant les devcontainers
URL="https://github.com/theo-coder/docker-init.git"

# Initialisation des fichiers configs
mkdir -p ~/.config/docker-init
touch ~/.config/docker-init/techs

inputInstalleds=$(cat ~/.config/docker-init/techs)
IFS=',' read -ra installeds <<< "$inputInstalleds"

# Test validité de la commande
if [ $# -eq 0 ] || [ $# -eq 1 ]; then
    echo -e "\e[33m⚠  \e[39mPas assez d'arguments fournis \e[32m-> \e[36m\$ \e[39mdocker-init \e[90m<\e[39mtechnologie\e[90m> <\e[39mnom-du-projet\e[90m>"
    exit 0
fi

# Création du dossier du projet
mkdir -p $2

# Si la tech avait déjà été téléchargée
for installed in ${installeds[*]}; do
    if [ $1 = $installed ]; then
        cp -r ~/.config/docker-init/$1/.devcontainer ./$2
        echo -e "\e[32m√\e[39m Votre projet est prêt \e[32m->\e[39m $(pwd)/$2"
        exit 1
    fi
done

# Liste des branches en remotes / techs
inputRemotes=$(git ls-remote --heads $URL | tr '\r\n' ' ')
IFS=' ' read -ra remotes <<< "$inputRemotes"

# Boucle sur les remotes pour alimenter le tableau des techs
techs=()
count=0

for line in ${remotes[*]}; do
    if (( $count % 2 )); then

        IFS='/' read -ra remote <<< "$line"
        tech=${remote[2]};

        if [[ $tech != "main" ]]; then
            techs+=($tech)
        fi
    fi
    count=$(( $count+1 ))
done

# Boucle sur les techs pour vérifier l'argument
null=1
for tech in ${techs[*]}; do
    if [ $1 = $tech ]; then
        mkdir -p ~/.config/docker-init/$tech
        git clone -b $1 $URL ~/.config/docker-init/$tech >/dev/null
        echo "$tech," >> ~/.config/docker-init/techs
        cp -r ~/.config/docker-init/$tech/.devcontainer ./$2
        null=0
        echo -e "\e[32m√\e[39m Votre projet est prêt \e[32m->\e[39m $(pwd)/$2"
    fi
done

# Si la tech n'est pas trouvée
if [ $null = 1 ]; then
    echo -e "\e[33m⚠  \e[39mCette technologie n'existe pas"
    rm -rf $2
    exit 0
fi