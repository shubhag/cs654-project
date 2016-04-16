#!/bin/bash

scp -i ~/Downloads/lucky.pem public/uploads/code.zip ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~
scp -i ~/Downloads/lucky.pem ~/Course/docker-ssh/node-docker ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~

ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com<< 'ENDSSH'
sudo su
rm -rf server/
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
unzip server.zip
mv node-docker server/Dockerfile
cd server
docker build -t user-node .
docker run -p 80:80 -d --name web user-node
ENDSSH