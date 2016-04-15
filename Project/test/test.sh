 #!/bin/bash 
COUNTER=4
i=1
until [  $i -gt $COUNTER ]; do
 echo $i $COUNTER
 let i+=1
done