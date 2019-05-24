#!/usr/bin/env bash

set -e
set -x

SUCCESS=0

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

trap cleanup exit

./run.sh start network


expect() {
	local expected="$1"
	local actual="$(curl -s http://localhost:8080/)"
	if [[ "$expected" != "$actual" ]]; then
		echo "Unexpected response: $actual";
		return 1;
	fi
	return 0;
}

./run.sh start backend1
./run.sh start root

expect "This is backend 1"

./run.sh start backend2
sleep .2;

expect "This is backend 1"

./run.sh stop backend1
sleep .2;

expect "This is backend 2"

./run.sh start backend1
./run.sh reload root

sleep .2;
expect "This is backend 1"


SUCCESS=1

