function hostn()
{
    local host='mongo'$1'.ttnd.com'
    echo "$host"
}

function repn()
{
	local repset='tt'$1
	echo "$repset"
}
nshards=2
for i in `seq 1 $nshards`;
do
	let "id1=$i*3-2" 
	echo $id1
	echo $i
	a=$(repn $i)'/'$(hostn $id1)':27017'
	echo $a
	sh.addShard(\"$a\")
done