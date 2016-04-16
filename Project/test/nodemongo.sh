#!/bin/bash
echo $1 > ~/Course/docker-ssh/configure.txt
tar -zcvf ~/Course/docker-ssh.tar.gz ~/Course/docker-ssh

scp -i ~/Downloads/cse.pem ~/Course/docker-ssh.tar.gz ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com:~

ssh -T -i ~/Downloads/cse.pem ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com "bash -s" $1 << 'ENDSSH'
sudo su
rm -rf "home/shubham/Course/docker-ssh/"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "home/shubham/Course/docker-ssh/"
ty=$(sed -n '1p' < configure.txt)
if [ $ty = "4" ]; then
	sudo docker run -p 27017:27017 --name mongo -d mongo
fi

mv node-docker server/Dockerfile
cd server
docker build -t user-node .

if [ $ty = "1" ]; then
	docker run -p 80:80 -d --name web user-node
elif [ $ty = "4" ]; then
	docker run -p 80:80 -d --name web --link mongo:mongo user-node
fi

ENDSSH