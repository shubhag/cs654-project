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
result=$(hostn $1)
repset=$(repn $id)
i=1
id1=1
a=$(repn $i)'/'$(hostn $id1)':27017'
echo $a
echo $repset