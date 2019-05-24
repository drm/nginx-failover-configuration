#!/usr/bin/env bash

set -e
set -x

SUCCESS=0

##
# Opens the url and compares the output to the expected first parameter.
##
expect() {
	local expected="$1"
	local actual="$(curl -s http://localhost:8080/)"
	if [[ "$expected" != "$actual" ]]; then
		echo "Unexpected response: $actual";
		return 1;
	fi
	return 0;
}

##
# Tear down the dockers used for testing
##
cleanup() {
	set +x
	./run.sh stop 
	echo ""
	if [[ "$SUCCESS" == "0" ]]; then
		echo "Failed :(";
	else
		echo "Success! :)"
	fi
}

#############################################################################
# Initialization

# Make sure the cleanup is done when the script exits.
trap cleanup exit

# Initialize docker network
./run.sh start network

#############################################################################
# First, start the first backend and the root proxy.
./run.sh start backend1
./run.sh start root

expect "This is backend 1"


#############################################################################
# The result should be the same, even though backend 2 is available:
./run.sh start backend2
sleep .2;

expect "This is backend 1"
expect "This is backend 1"
expect "This is backend 1"


#############################################################################
# Now, with the first backend down, we expect to get the contents from 
# backend 2:
./run.sh stop backend1
sleep .2;

expect "This is backend 2"


#############################################################################
# Revive backend 1 and reload NginX, we should get backend 1 again

./run.sh start backend1
./run.sh reload root

sleep .2;
expect "This is backend 1"

#############################################################################
# If we made it until here, the test succeeded

SUCCESS=1

