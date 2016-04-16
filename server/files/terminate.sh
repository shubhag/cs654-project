#!/bin/bash

ssh -T -i ~/Downloads/lucky.pem ubuntu@ec2-52-37-160-33.us-west-2.compute.amazonaws.com << 'ENDSSH'
docker rm -f $(docker ps -a -q)
ENDSSH