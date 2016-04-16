#!/bin/bash
Counter=3000
ipmap=""
match="/ip_hash;/a "
for i in `seq 1 $1`;
do
	let "Counter=Counter+1"
	ipmap=$ipmap' server '$2':'$Counter';'
done
sed -e "/ip_hash;/a ${ipmap}" config.txt > ~/Course/docker-ssh/nginx.conf

scp -i ~/Downloads/cse.pem ~/Course/docker-ssh/server.zip ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com:~
scp -i ~/Downloads/cse.pem ~/Course/docker-ssh/node-docker ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com:~
scp -i ~/Downloads/cse.pem ~/Course/docker-ssh/nginx-docker ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com:~
scp -i ~/Downloads/cse.pem ~/Course/docker-ssh/nginx.conf ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com:~

ssh -T -i ~/Downloads/cse.pem ubuntu@ec2-52-38-241-73.us-west-2.compute.amazonaws.com "bash -s" $1 << 'ENDSSH'
num=$1
echo $num
sudo su
rm -rf server/
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
unzip server.zip
mv node-docker server/Dockerfile
cd server
docker build -t user-node .

Counter=3000
sname="web"
for i in `seq 1 3`;
do
	let "Counter=Counter+1"
	sn="$sname$i"
	docker run -p $Counter:80 -d --name $sn user-node
	echo $i
done

cd ..
rm -rf nginx/
mkdir nginx
mv nginx-docker nginx/Dockerfile
mv nginx.conf nginx/nginx.conf

cd nginx
docker build -t user-nginx .
docker run -d -p 80:80 user-nginx
ENDSSH