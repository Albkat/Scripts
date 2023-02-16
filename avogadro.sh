#!/bin/bash

# Script to automatically install Avogadro 1 to Ubuntu 20

# Installation of docker - software to deliver Avogadro as a container. See for more details: https://docs.docker.com/get-started/overview/

## to use a repository over HTTPS
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

## to add docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

## to make repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


## to remove older versions of Docker
#sudo apt-get remove docker docker-engine docker.io containerd runc
#sudo apt-get docker.io containerd

## to update package index
apt-cache madison docker-ce
if [ $? -eq 1 ]; then
    echo "You have only old versions of Docker available for your Linux distribution"
    sudo apt-get update

    # Actual installation
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get docker.io containerd
else
    apt-cache madison docker-ce> output.txt
    version=$(head -n 1 output.txt | awk '{print $3}')
    echo "You have new version of Docker available"
    sudo apt-get update
    sudo apt-get install docker-ce=$version docker-ce-cli=$version containerd.io
fi


echo "TO CHECK hello-world"

## Automatically downloads image and creates container
sudo docker run hello-world

# TO RUN DOCKER WITHOUT sudo
## to create group
sudo groupadd docker

## to add user to it
sudo usermod -aG docker $USER
newgrp docker

echo "TO CHECK hellow-world without sudo"
docker run hello-world

cat <<'EOF' >>avogadro
#!/usr/bin/bash

export XSOCK=/tmp/.X11-unix
export XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

if [ -z $1 ]; then
docker run -itd -w $PWD --rm \
       --volume=$PWD:$PWD:z \
       --volume=$XSOCK:$XSOCK:rw \
       --volume=$XAUTH:$XAUTH:rw \
       --env="XAUTHORITY=${XAUTH}" \
       --env="DISPLAY" \
       --env="QT_X11_NO_MITSHM=1" \
       --user "$(id -u):$(id -g)" \
       ghcr.io/awvwgk/avogadro
     else
docker run -itd -w $PWD --rm \
       --volume=$PWD:$PWD:z \
       --volume=$XSOCK:$XSOCK:rw \
       --volume=$XAUTH:$XAUTH:rw \
       --env="XAUTHORITY=${XAUTH}" \
       --env="DISPLAY" \
       --env="QT_X11_NO_MITSHM=1" \
       --user "$(id -u):$(id -g)" \
       ghcr.io/awvwgk/avogadro $PWD/$1
fi
EOF
chmod u+x avogadro

if [ -d ~/bin ]; then
    mv avogadro ~/bin
else
    mkdir ~/bin
    mv avogadro ~/bin
    echo 'export PATH="~/bin:PATH"' >> ~/.bashrc
    source ~/.bashrc
fi


