#!/bin/bash

rm -rf docker
mkdir docker
unzip public/uploads/code -d docker/
cp -a files/. docker/
cd docker
mv nodejs-dockerfile dockerfile


# do something

rm dockerfile
