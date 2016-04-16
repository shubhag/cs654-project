#!/bin/bash
#1st arg- type
#2nd arg- ip
#3rd arg- number of server present 
#4th arg- number of server to add 

ssh -T -i ~/Downloads/cse.pem ubuntu@ec2-52-32-149-178.us-west-2.compute.amazonaws.com "bash -s" $1 << 'ENDSSH'
sudo su
docker rm -f $(docker ps -a -q)
ENDSSH