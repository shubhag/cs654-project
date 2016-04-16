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
ty=6
if [ $ty = "2" ]; then
	echo $ty
elif [ $ty = "3" ]; then
	echo $ty
elif [ $ty = "5" ]; then
	echo $ty
elif [ $ty = "6" ]; then
	echo $ty
fi