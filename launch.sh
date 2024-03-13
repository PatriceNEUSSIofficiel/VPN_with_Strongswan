#!/bin/bash

# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker ${USER}

# Modifier les permissions sur le fichier docker.sock
sudo setfacl --modify user:${USER}:rw /var/run/docker.sock

cd /home/patrice/Desktop/INFOL3/admin/reseau/TP/strongswan

# Lancement du conteneur Ubuntu 1
docker run -tid --privileged --name ubuntu1-container -v /var/run/docker.sock:/var/run/docker.sock ubuntu1-image sleep infinity

# Attente pour permettre au conteneur Ubuntu de démarrer complètement
sleep 5

# Lancement des trois conteneurs CentOS à l'intérieur du conteneur Ubuntu
docker exec -i ubuntu1-container bash -c 'docker run -itd --network ubuntu_net --name centos1 centos'
docker exec -i ubuntu1-container bash -c 'docker run -itd --network ubuntu_net --name centos2 centos'
docker exec -i ubuntu1-container bash -c 'docker run -itd --network ubuntu_net --name centos3 centos'

# Installation de ping dans chaque conteneur CentOS
docker exec -i ubuntu1-container bash -c 'docker exec -itd centos1 yum install -y iputils-ping'
docker exec -i ubuntu1-container bash -c 'docker exec -itd centos2 yum install -y iputils-ping'
docker exec -i ubuntu1-container bash -c 'docker exec -itd centos3 yum install -y iputils-ping'

# Lancement du conteneur Ubuntu 2
docker run -tid --privileged --name ubuntu2-container -v /var/run/docker.sock:/var/run/docker.sock ubuntu2-image sleep infinity

# Attente pour permettre au conteneur Ubuntu de démarrer complètement
sleep 5

# Lancement des trois conteneurs CentOS à l'intérieur du conteneur Ubuntu
docker exec -i ubuntu2-container bash -c 'docker run -itd --network ubuntu_net2 --name centos4 centos'
docker exec -i ubuntu2-container bash -c 'docker run -itd --network ubuntu_net2 --name centos5 centos'
docker exec -i ubuntu2-container bash -c 'docker run -itd --network ubuntu_net2 --name centos6 centos'

# Installation de ping dans chaque conteneur CentOS
docker exec -i ubuntu2-container bash -c 'docker exec -itd centos4 yum install -y iputils-ping'
docker exec -i ubuntu2-container bash -c 'docker exec -itd centos5 yum install -y iputils-ping'
docker exec -i ubuntu2-container bash -c 'docker exec -itd centos6 yum install -y iputils-ping'

# Affichage des adresses IP des conteneurs et du réseau
docker exec -i ubuntu1-container bash -c 'docker network inspect ubuntu_net | grep IPAddress'
docker exec -i ubuntu1-container bash -c 'docker inspect --format="{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $(docker ps -aq)'

docker exec -i ubuntu2-container bash -c 'docker network inspect ubuntu_net2 | grep IPAddress'
docker exec -i ubuntu2-container bash -c 'docker inspect --format="{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $(docker ps -aq)'