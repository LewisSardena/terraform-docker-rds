#!/bin/bash

#Add utils

yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

#Add Docker repo

yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

#Install Docker

yum install -y docker-ce


#Add user to Docker gorup

usermod -aG docker ec2-user
