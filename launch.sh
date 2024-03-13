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
eho "centos-container(1,2,3,4,5,6) ips : "
docker exec -i ubuntu1-container bash -c 'docker network inspect ubuntu_net | grep IPAddress'
docker exec -i ubuntu1-container bash -c 'docker inspect --format="{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $(docker ps -aq)'
#ubuntu_net "Subnet": "172.24.0.0/16" : centos3 - 172.24.0.4 centos2 - 172.24.0.3 centos1 - 172.24.0.2 
#ubuntu_net2 "Subnet": "172.25.0.0/16" : centos6 - 172.25.0.4 centos5 - 172.25.0.3 centos4 - 172.25.0.2 
eho "ubuntu1-container ip : "
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ubuntu1-container
#ubuntu1-container : 172.17.0.2 "Subnet": "172.17.0.0/16",
eho "ubuntu2-container ip : "
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ubuntu2-container
#ubuntu2-container : 172.17.0.3 "Subnet": "172.17.0.0/16",
