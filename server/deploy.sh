#!/bin/bash

cd /public/uploads/
for file in "$PATH_TO_SOMEWHERE"; 
do
	if [ -d $file ]
	then
	    # do something directory-ish
	else
		if [[ $file == code.zip ]]      
		then
		    ls
		fi
	fi
done;
unzip code.zip
# rm -rf docker
# mkdir docker
# cd docker
# cerate new folder here
# unzip