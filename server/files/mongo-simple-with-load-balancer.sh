#!/bin/bash

rm -rf ../docker-ssh/server/
mkdir ../docker-ssh/server/
mv public/uploads/code public/uploads/code.zip
unzip public/uploads/code.zip -d ../docker-ssh/server/

Counter=3000
ipmap=""
match="/ip_hash;/a "
# ipaddr = $1
# number_of_servers = $2
for i in `seq 1 $2`;
do
	let "Counter=Counter+1"
	ipmap=$ipmap' server '$1':'$Counter';'
done
sed -e "/ip_hash;/a ${ipmap}" ../docker-ssh/config.txt > ../docker-ssh/nginx.conf
# echo $1 > ../docker-ssh/configure.txt
echo $2 > ../docker-ssh/configure.txt
tar -zcvf ../docker-ssh.tar.gz ../docker-ssh
scp -i ~/Downloads/lucky.pem ../docker-ssh.tar.gz ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~
rm ../docker-ssh.tar.gz
ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com << 'ENDSSH'

sudo su

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "docker-ssh/"
sudo docker run -p 27017:27017 --name mongo -d mongo

mv node-docker server/Dockerfile
num=$(sed -n '1p' < configure.txt)
cd server
docker build -t user-node .

Counter=3000
sname="web"
echo $ty
for i in `seq 1 $num`;
do
	let "Counter=Counter+1"
	sn="$sname$i"
	docker run -p $Counter:80 -d --name $sn --link mongo:mongo user-node
done

cd ..
rm -rf nginx/
mkdir nginx
mv nginx-docker nginx/Dockerfile
mv nginx.conf nginx/nginx.conf

cd nginx
docker build -t user-nginx .
docker run -d -p 80:80 --name ng user-nginx

ENDSSH

echo "Server has started"