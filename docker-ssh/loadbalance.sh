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
# for i in `seq 1 $num`;
# do
# 	echo $num
# 	let "Counter=Counter+1"
# 	sn="$sname$i"
# 	docker run -p $Counter:80 -d --name $sn user-node
# 	echo $i
# done

i=1
num=$(head -n 1 configure.txt)
echo $num
until [$i -gt $num]; do
	let "Counter=Counter+1"
	sn="$sname$i"
	docker run -p $Counter:80 -d --name $sn user-node
	let i+=1
	
done
cd ..
rm -rf nginx/
mkdir nginx
mv nginx-docker nginx/Dockerfile
mv nginx.conf nginx/nginx.conf

cd nginx
docker build -t user-nginx .
docker run -d -p 80:80 user-nginx