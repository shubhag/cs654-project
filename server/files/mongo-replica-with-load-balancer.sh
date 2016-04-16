#!/bin/bash

rm -rf ../docker-ssh/server/
mkdir ../docker-ssh/server/
mv public/uploads/code public/uploads/code.zip
unzip public/uploads/code.zip -d ../docker-ssh/server/

Counter=3000
ipmap=""
match="/ip_hash;/a "
for i in `seq 1 $2`;
do
	let "Counter=Counter+1"
	ipmap=$ipmap' server '$1':'$Counter';'
done
sed -e "/ip_hash;/a ${ipmap}" ../docker-ssh/config.txt > ../docker-ssh/nginx.conf
# echo $1 > ../docker-ssh/configure.txt
echo $2 >> ../docker-ssh/configure.txt
tar -zcvf ../docker-ssh.tar.gz ../docker-ssh

scp -i ~/Downloads/lucky.pem ../docker-ssh.tar.gz ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com:~

##################################################################################
ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com << 'ENDSSH'
sudo su
# docker stop $(docker ps -a -q)
docker rm -f $(docker ps -a -q)
tar -xvf docker-ssh.tar.gz
cd "docker-ssh/"

###########------------Mongo replication code-------------#####################
h1="mongo1.ttnd.com"
h2="mongo2.ttnd.com"
h3="mongo3.ttnd.com"
 
# Start containers with specific hostnames and replica set name
docker run -p 27017:27017 --name ttnd1 --hostname="$h1" -d shubhag/mongo --replSet ttnd --noprealloc --smallfiles
docker run -p 27018:27017 --name ttnd2 --hostname="$h2" -d shubhag/mongo --replSet ttnd --noprealloc --smallfiles
docker run -p 27019:27017 --name ttnd3 --hostname="$h3" -d shubhag/mongo --replSet ttnd --noprealloc --smallfiles
 
# Commands to extract IP addresses of containers
echo "127.0.0.1 localhost" > getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd1) "$h1" >> getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd2) "$h2" >> getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd3) "$h3" >> getip.txt

cat getip.txt
# Commands to cp getip.txt to containers
docker cp getip.txt ttnd1:/etc
docker cp getip.txt ttnd2:/etc
docker cp getip.txt ttnd3:/etc
 
# Commands to create new file updateHost.sh (to update /etc/hosts file in all the three docker containers)
echo "#!/bin/bash
cat /etc/hosts > /etc/hosts1
sed -i '/ttnd.com/d' /etc/hosts1
cat /etc/getip.txt >> /etc/hosts1
cat /etc/hosts1 > /etc/hosts" > updateHost.sh
 
# Change permission of updateHost.sh and cp files to docker container
chmod +x updateHost.sh
docker cp updateHost.sh ttnd1:/etc
docker cp updateHost.sh ttnd2:/etc
docker cp updateHost.sh ttnd3:/etc
echo "hi"
docker exec -t ttnd1 chmod +x /etc/updateHost.sh
echo "qw"
docker exec -t ttnd2 chmod +x /etc/updateHost.sh
docker exec -t ttnd3 chmod +x /etc/updateHost.sh
 
# Execute scripts on all the three containers
docker exec -t ttnd1 /etc/updateHost.sh
docker exec -t ttnd2 /etc/updateHost.sh
docker exec -t ttnd3 /etc/updateHost.sh
# Start MongoDB Replica Set with Primary
docker exec -t ttnd1 mongo --eval "rs.status()"
docker exec -t ttnd1 mongo --eval "db"
docker exec -t ttnd1 mongo --eval "rs.initiate()"
sleep 120
docker exec -t ttnd1 mongo --eval "rs.add(\"$h2:27017\")"
docker exec -t ttnd1 mongo --eval "rs.add(\"$h3:27017\")"
docker exec -t ttnd2 mongo --eval "rs.slaveOk()"
docker exec -t ttnd3 mongo --eval "rs.slaveOk()"


repip1=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd1)
repip2=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd2)
repip3=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd3)
echo $repip1
echo $repip2
echo $repip3
cp getip.txt /etc/hosts
################-------mongo replication ends-------------------##################


mv node-docker server/Dockerfile
num=$(sed -n '1p' < configure.txt)
echo 'num'
echo $num
cd server
docker build -t user-node .

Counter=3000
sname="web"
for i in `seq 1 $num`;
do
	let "Counter=Counter+1"
	sn="$sname$i"
	docker run -p $Counter:80 -d --name $sn --link ttnd1:ttnd1 user-node
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