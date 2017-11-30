#!/bin/bash

#Add utils

sudo yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

#Add Docker repo

sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

#Install Docker

sudo yum install -y docker-ce


#Add user to Docker gorup

sudo usermod -aG docker ec2-user
