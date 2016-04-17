#!/bin/bash
#1st arg- type
#2nd arg- ip
#3rd arg- number of server present 
#4th arg- number of server to add 

Counter=3000
ipmap=""
match="/ip_hash;/a "
let "nserver=$3+$4"
for i in `seq 1 $nserver`;
do
	let "Counter=Counter+1"
	ipmap=$ipmap' server '$2':'$Counter';'
done
sed -e "/ip_hash;/a ${ipmap}" ../docker-ssh/config.txt > ../docker-ssh/nginx.conf
echo $3 > ../docker-ssh/configure.txt
echo $4 >> ../docker-ssh/configure.txt
echo $1 >> ../docker-ssh/configure.txt

scp -i ~/Downloads/lucky.pem ../docker-ssh/configure.txt $5:~
scp -i ~/Downloads/lucky.pem ../docker-ssh/nginx.conf $5:~

##################################################################################
ssh -T -i ~/Downloads/lucky.pem $5 << 'ENDSSH'
sudo su

nini=$(sed -n '1p' < configure.txt)
nadd=$(sed -n '2p' < configure.txt)
ty=$(sed -n '3p' < configure.txt)

let "nstart=$nini+1"
let "nserver=$nini+$nadd"
Counter=3000
let "Counter=$Counter+$nini"
sname="web"
for i in `seq $nstart $nserver`;
do
	let "Counter=Counter+1"
	sn="$sname$i"
	if [ $ty = "3" ]; then
		docker run -p $Counter:80 -d --name $sn user-node
	elif [ $ty = "4" ]; then
		docker run -p $Counter:80 -d --name $sn --link mongo:mongo user-node
	elif [ $ty = "5" ]; then
		docker run -p $Counter:80 -d --name $sn --link ttnd1:ttnd1 user-node
	elif [ $ty = "6" ]; then
		docker run -p $Counter:80 -d --name $sn --link mongos:mongos user-node
	fi
done

mv nginx.conf home/shubham/Course/docker-ssh/nginx/nginx.conf

docker stop -f ng
docker rm -f ng
cd home/shubham/Course/docker-ssh/nginx
docker build -t user-nginx .
docker run -d -p 80:80 --name ng user-nginx
ENDSSH