#!/bin/bash
rm -rf ../docker-ssh/server/
mkdir ../docker-ssh/server/
mv public/uploads/code public/uploads/code.zip
unzip public/uploads/code.zip -d ../docker-ssh/server/
tar -zcvf ../docker-ssh.tar.gz ../docker-ssh
scp -i ~/Downloads/lucky.pem ../docker-ssh.tar.gz ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~
rm ../docker-ssh.tar.gz
ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com << 'ENDSSH'
sudo su
docker rm -f $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "docker-ssh/"
ty=$(sed -n '1p' < configure.txt)
sudo docker run -p 27017:27017 --name mongo -d mongo

mv node-docker server/Dockerfile
cd server
docker build -t user-node .

docker run -p 80:80 -d --name web --link mongo:mongo user-node

ENDSSH

echo "Server has started"