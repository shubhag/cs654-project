#!/bin/bash
#1st arg- type
#2nd arg- ip
#3rd arg- number of server present 
Counter=3000
ipmap=""
match="/ip_hash;/a "
for i in `seq 1 $3`;
do
	let "Counter=Counter+1"
	ipmap=$ipmap' server '$2':'$Counter';'
done
sed -e "/ip_hash;/a ${ipmap}" config.txt > ~/Course/docker-ssh/nginx.conf
echo $1 > ~/Course/docker-ssh/configure.txt
echo $3 >> ~/Course/docker-ssh/configure.txt
tar -zcvf ~/Course/docker-ssh.tar.gz ~/Course/docker-ssh

scp -i ~/Downloads/cse.pem ~/Course/docker-ssh.tar.gz ubuntu@ec2-52-32-149-178.us-west-2.compute.amazonaws.com:~

##################################################################################
ssh -T -i ~/Downloads/cse.pem ubuntu@ec2-52-32-149-178.us-west-2.compute.amazonaws.com "bash -s" $1 << 'ENDSSH'
sudo su
rm -rf "home/shubham/Course/docker-ssh/"
# docker stop $(docker ps -a -q)
docker rm -f $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "home/shubham/Course/docker-ssh/"
ty=$(sed -n '1p' < configure.txt)
if [ $ty = "3" ]; then
	sudo docker run -p 27017:27017 --name mongo -d mongo
fi

mv node-docker server/Dockerfile
num=$(sed -n '2p' < configure.txt)
cd server
docker build -t user-node .

Counter=3000
sname="web"
echo $ty
for i in `seq 1 $num`;
do
	let "Counter=Counter+1"
	sn="$sname$i"
	if [ $ty = "2" ]; then
		docker run -p $Counter:80 -d --name $sn user-node
	elif [ $ty = "3" ]; then
		docker run -p $Counter:80 -d --name $sn --link mongo:mongo user-node
	fi
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