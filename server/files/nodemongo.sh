#!/bin/bash
rm -rf ../docker-ssh/server/
mkdir ../docker-ssh/server/
mv public/uploads/code public/uploads/code.zip
unzip public/uploads/code.zip -d ../docker-ssh/server/
echo $1 > ../docker-ssh/configure.txt
tar -zcvf ../docker-ssh.tar.gz ../docker-ssh
scp -i ~/Downloads/lucky.pem ../docker-ssh.tar.gz ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~
rm ../docker-ssh.tar.gz
ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com << 'ENDSSH'
sudo su
# rm -rf "home/shubham/Course/docker-ssh/"
docker rm -f $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "docker-ssh/"
ty=$(sed -n '1p' < configure.txt)
if [ $ty = "4" ]; then
	sudo docker run -p 27017:27017 --name mongo -d mongo
fi

mv node-docker server/Dockerfile
cd server
docker build -t user-node .

if [ $ty = "1" ]; then
	echo "Running Simple Node Server"
	docker run -p 80:80 -d --name web user-node
elif [ $ty = "4" ]; then
	docker run -p 80:80 -d --name web --link mongo:mongo user-node
fi

ENDSSH

echo "done"