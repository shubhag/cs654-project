#!/bin/bash

#########--------Replica set 1-------------------------------##
###############################################################

# Define Hostnames
h1="mongo1.ttnd.com"
h2="mongo2.ttnd.com"
h3="mongo3.ttnd.com"
 
# Start containers with specific hostnames and replica set name
docker run -P --name ttnd1 --hostname="$h1" -d nmongo --replSet ttnda --noprealloc --smallfiles
docker run -P --name ttnd2 --hostname="$h2" -d nmongo --replSet ttnda --noprealloc --smallfiles
docker run -P --name ttnd3 --hostname="$h3" -d nmongo --replSet ttnda --noprealloc --smallfiles
 
# Commands to extract IP addresses of containers
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd1) "$h1" > getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd2) "$h2" >> getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd3) "$h3" >> getip.txt
 
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
docker exec -it ttnd1 chmod +x /etc/updateHost.sh
docker exec -it ttnd2 chmod +x /etc/updateHost.sh
docker exec -it ttnd3 chmod +x /etc/updateHost.sh
 
# Execute scripts on all the three containers
docker exec -it ttnd1 /etc/updateHost.sh
docker exec -it ttnd2 /etc/updateHost.sh
docker exec -it ttnd3 /etc/updateHost.sh
# Start MongoDB Replica Set with Primary
docker exec -it ttnd1 mongo --eval "rs.status()"
docker exec -it ttnd1 mongo --eval "db"
docker exec -it ttnd1 mongo --eval "rs.initiate()"
sleep 120
docker exec -it ttnd1 mongo --eval "rs.add(\"$h2:27017\")"
docker exec -it ttnd1 mongo --eval "rs.add(\"$h3:27017\")"
docker exec -it ttnd2 mongo --eval "rs.slaveOk()"
docker exec -it ttnd3 mongo --eval "rs.slaveOk()"

#######-------Replica set 2-----------------------------#
#########################################################
# Define Hostnames
h4="mongo4.ttnd.com"
h5="mongo5.ttnd.com"
h6="mongo6.ttnd.com"
 
# Start containers with specific hostnames and replica set name
docker run -P --name ttnd4 --hostname="$h4" -d nmongo --replSet ttndb --noprealloc --smallfiles
docker run -P --name ttnd5 --hostname="$h5" -d nmongo --replSet ttndb --noprealloc --smallfiles
docker run -P --name ttnd6 --hostname="$h6" -d nmongo --replSet ttndb --noprealloc --smallfiles
 
# Commands to extract IP addresses of containers
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd4) "$h4" > getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd5) "$h5" >> getip.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttnd6) "$h6" >> getip.txt
 
# Commands to cp getip.txt to containers
docker cp getip.txt ttnd4:/etc
docker cp getip.txt ttnd5:/etc
docker cp getip.txt ttnd6:/etc
 
# Commands to create new file updateHost.sh (to update /etc/hosts file in all the three docker containers)
echo "#!/bin/bash
cat /etc/hosts > /etc/hosts1
sed -i '/ttnd.com/d' /etc/hosts1
cat /etc/getip.txt >> /etc/hosts1
cat /etc/hosts1 > /etc/hosts" > updateHost.sh
 
# Change permission of updateHost.sh and cp files to docker container
chmod +x updateHost.sh
docker cp updateHost.sh ttnd4:/etc
docker cp updateHost.sh ttnd5:/etc
docker cp updateHost.sh ttnd6:/etc
docker exec -it ttnd4 chmod +x /etc/updateHost.sh
docker exec -it ttnd5 chmod +x /etc/updateHost.sh
docker exec -it ttnd6 chmod +x /etc/updateHost.sh
 
# Execute scripts on all the three containers
docker exec -it ttnd4 /etc/updateHost.sh
docker exec -it ttnd5 /etc/updateHost.sh
docker exec -it ttnd6 /etc/updateHost.sh
# Start MongoDB Replica Set with Primary
docker exec -it ttnd4 mongo --eval "rs.status()"
docker exec -it ttnd4 mongo --eval "db"
docker exec -it ttnd4 mongo --eval "rs.initiate()"
sleep 120
docker exec -it ttnd4 mongo --eval "rs.add(\"$h5:27017\")"
docker exec -it ttnd4 mongo --eval "rs.add(\"$h6:27017\")"
docker exec -it ttnd5 mongo --eval "rs.slaveOk()"
docker exec -it ttnd6 mongo --eval "rs.slaveOk()"

#########################################################
sudo docker run -P --name cfg1 -d nmongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017
sudo docker run -P --name cfg2 -d nmongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017
sudo docker run -P --name cfg3 -d nmongo --noprealloc --smallfiles --configsvr --dbpath /data/db --port 27017

cfg1ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg1`
cfg2ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg2`
cfg3ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' cfg3`
##############db router###################################
##########################################################
sudo docker run -P --name mongos1 -d gustavocms/mongos --port 27017 --configdb $cfg1ip:27017,$cfg2ip:27017,$cfg3ip:27017
