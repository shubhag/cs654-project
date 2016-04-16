#!/bin/bash
rm -rf ../docker-ssh/server/
mkdir ../docker-ssh/server/
mv public/uploads/code public/uploads/code.zip
unzip public/uploads/code.zip -d ../docker-ssh/server/
tar -zcvf ../docker-ssh.tar.gz ../docker-ssh
scp -i ~/Downloads/lucky.pem ../docker-ssh.tar.gz $1:~
rm ../docker-ssh.tar.gz
ssh -T -i ~/Downloads/lucky.pem $1 << 'ENDSSH'
sudo su
# rm -rf "home/shubham/Course/docker-ssh/"
docker rm -f $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "docker-ssh/"
mv node-docker server/Dockerfile
cd server
docker build -t user-node .
echo "Running Simple Node Server"
docker run -p 80:80 -d --name web user-node

ENDSSH

echo "Server has started"