sp="/-\|"
sc=0
spin() {
	printf "\b${sp:sc++:1}"
	((sc==${#sp})) && sc=0
}
endspin() {
	printf "\r%s\n" "$@"
}

do_spin() {
for i in $(seq $1)
do
	spin
	sleep 1
done
endspin
}

#!/bin/bash
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function ProgressBar {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress [${1}/${2}] : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}

function do_stuff()
{
	echo Test : $1
}
# Variables
_start=1

# This accounts as the "totalState" variable for the ProgressBar function
#_end=100
_end=$(find redfish -name "*.robot"  | grep -v __ | wc -l)
declare -a arr=($(find redfish -name "*.robot"  | grep -v __ ))


# Proof of concept
for number in $(seq ${_start} ${_end})
do
    sleep 0.1
	printf "\nTest#${number} \n"
	do_stuff "${arr[${number}]}"
    ProgressBar ${number} ${_end}
done
printf '\nFinished!\n'
