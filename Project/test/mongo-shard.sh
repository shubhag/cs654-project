#!/bin/bash
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
echo $4 >> ~/Course/docker-ssh/configure.txt
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

###########------------Mongo sharding code-------------#####################

nshards=$(sed -n '3p' < configure.txt)
echo "" > getip.txt

function hostn()
{
    local host='mongo'$1'.ttnd.com'
    echo "$host"
}

function name()
{
    local name='ttnd'$1
    echo "$name"
}

function repn()
{
	local repset='tt'$1
	echo "$repset"
}

# Commands to create new file updateHost.sh (to update /etc/hosts file in all the three docker containers)
echo "#!/bin/bash
cat /etc/hosts > /etc/hosts1
sed -i '/ttnd.com/d' /etc/hosts1
cat /etc/getip.txt >> /etc/hosts1
cat /etc/hosts1 > /etc/hosts" > updateHost.sh
chmod +x updateHost.sh

for i in `seq 1 $nshards`;
do
	let "id1=$i*3-2" 
	let "id2=$i*3-1" 
	let "id3=$i*3" 
	
	docker run -P --name $(name $id1) --hostname="$(hostn $id1)" -d shubhag/mongo --replSet $(repn $i) --noprealloc --smallfiles
	docker run -P --name $(name $id2) --hostname="$(hostn $id2)" -d shubhag/mongo --replSet $(repn $i) --noprealloc --smallfiles
	docker run -P --name $(name $id3) --hostname="$(hostn $id3)" -d shubhag/mongo --replSet $(repn $i) --noprealloc --smallfiles

	echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(name $id1)) "$(hostn $id1)" >> getip.txt
	echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(name $id2)) "$(hostn $id2)" >> getip.txt
	echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(name $id3)) "$(hostn $id3)" >> getip.txt

	# Commands to cp getip.txt to containers
	docker cp getip.txt $(name $id1):/etc
	docker cp getip.txt $(name $id2):/etc
	docker cp getip.txt $(name $id3):/etc

	#to update /etc/hosts file in all the three docker containers
	docker cp updateHost.sh $(name $id1):/etc
	docker cp updateHost.sh $(name $id2):/etc
	docker cp updateHost.sh $(name $id3):/etc
	docker exec -t $(name $id1) chmod +x /etc/updateHost.sh
	docker exec -t $(name $id2) chmod +x /etc/updateHost.sh
	docker exec -t $(name $id3) chmod +x /etc/updateHost.sh

	# Execute scripts on all the three containers
	docker exec -t $(name $id1) /etc/updateHost.sh
	docker exec -t $(name $id2) /etc/updateHost.sh
	docker exec -t $(name $id3) /etc/updateHost.sh
	# Start MongoDB Replica Set with Primary
	docker exec -t $(name $id1) mongo --eval "rs.status()"
	docker exec -t $(name $id1) mongo --eval "db"
	docker exec -t $(name $id1) mongo --eval "rs.initiate()"
	sleep 10
	docker exec -t $(name $id1) mongo --eval "rs.add(\"$(hostn $id2):27017\")"
	docker exec -t $(name $id1) mongo --eval "rs.add(\"$(hostn $id3):27017\")"
	docker exec -t $(name $id1) mongo --eval "rs.slaveOk()"
	docker exec -t $(name $id1) mongo --eval "rs.slaveOk()"
done
cp getip.txt /etc/hosts

#set up mongo configuration server
docker run -P --name cfg1 -d shubhag/mongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017
docker run -P --name cfg2 -d shubhag/mongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017
docker run -P --name cfg3 -d shubhag/mongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017

#start mongos router
cfg1ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg1`
cfg2ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg2`
cfg3ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg3`

docker run -P --name mongos -d -e 'MONGO_MODE=mongos' shubhag/mongos --port 27017 --configdb $cfg1ip:27017,$cfg2ip:27017,$cfg3ip:27017
docker cp getip.txt mongos:/etc
docker cp updateHost.sh mongos:/etc
docker exec -t mongos chmod +x /etc/updateHost.sh
docker exec -t mongos /etc/updateHost.sh
# docker exec -t mongos mongo --eval "rs.initiate()"
docker exec -t mongos mongo --eval "rs.status()"
docker exec -t mongos mongo --eval "db"
sleep 20
for i in `seq 1 $nshards`;
do
	let "id1=$i*3-2" 
	echo $id1
	echo $i
	a=$(repn $i)'/'$(hostn $id1)':27017'
	echo $a
done
docker exec -i mongos mongo <<EOF
sh.addShard("tt1/mongo1.ttnd.com:27017")
sh.addShard("tt2/mongo4.ttnd.com:27017")
sh.status()
EOF
# docker exec -t mongos mongo --eval "rs.addShard("tt1/mongo1.ttnd.com:27017")"
# docker exec -t mongos mongo --eval "rs.addShard(\"tt2/mongo4.ttnd.com:27017\")"
################-------mongo sharding ends-------------------##################


mv node-docker server/Dockerfile
num=$(sed -n '2p' < configure.txt)
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
	docker run -p $Counter:80 -d --name $sn --link mongos:mongos user-node
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