#!/bin/bash
# Define Hostnames
h1="mongo1.ttnd.com"
h2="mongo2.ttnd.com"
h3="mongo3.ttnd.com"
 
# Start containers with specific hostnames and replica set name
docker run -p 27017:27017 --name ttnd1 --hostname="$h1" -d nmongo --replSet ttnd --noprealloc --smallfiles
docker run -p 27018:27017 --name ttnd2 --hostname="$h2" -d nmongo --replSet ttnd --noprealloc --smallfiles
docker run -p 27019:27017 --name ttnd3 --hostname="$h3" -d nmongo --replSet ttnd --noprealloc --smallfiles
 
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