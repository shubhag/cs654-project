FROM	ubuntu:14.04

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list

RUN apt-get update 
#RUN apt-get install -y mongodb-org
RUN apt-get install -y mongodb-org git python build-essential curl
CMD service mongod start

RUN 	apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists
RUN		curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
RUN		apt-get update && apt-get install -y nodejs 

COPY	package.json /src/package.json
RUN		cd /src; npm install --production

COPY	. /src

EXPOSE  80
EXPOSE	27017
CMD service mongod status > ~/hell.txt

CMD		["node", "/src/app.js"]
