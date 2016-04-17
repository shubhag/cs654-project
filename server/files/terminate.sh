#!/bin/bash

ssh -T -i ~/Downloads/lucky.pem $1 << 'ENDSSH'
sudo su
docker rm -f $(docker ps -a -q)
ENDSSH