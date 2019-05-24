dir=$(cd $(dirname "$0") && pwd);

start_network() {
	docker network create --subnet=172.16.88.0/24 proxy-setup-test
}

stop_network() {
	docker network rm proxy-setup-test || true
}

start() {
	start_network;
	start_root;
	start_backend1;
	start_backend2;
}

stop() {
	stop_root;
	stop_backend1;
	stop_backend2;
	stop_network;
}

stop_root() {
	docker rm -f proxy-setup-test--root 
}

reload_root() {
	docker exec proxy-setup-test--root nginx -s reload
}

stop_backend1() {
	docker rm -f proxy-setup-test--backend-1
}

stop_backend2() {
	docker rm -f proxy-setup-test--backend-2
}

start_root() {
	docker run \
		-p 8080:8080 \
		-d \
		-v $dir/root.conf:/etc/nginx/conf.d/default.conf \
		--network proxy-setup-test \
		--ip=172.16.88.71 \
		--name=proxy-setup-test--root \
		nginx
}

start_backend1() {
	docker run \
		-d \
		-v $dir/backend-1.conf:/etc/nginx/conf.d/default.conf \
		-v $dir/html/backend-1/:/var/www/html/ \
		--network proxy-setup-test \
		--ip=172.16.88.72 \
		--name=proxy-setup-test--backend-1 \
		nginx
}

start_backend2() {
	docker run \
		-d \
		-v $dir/backend-2.conf:/etc/nginx/conf.d/default.conf \
		-v $dir/html/backend-2/:/var/www/html/ \
		--network proxy-setup-test \
		--ip=172.16.88.73 \
		--name=proxy-setup-test--backend-2 \
		nginx
}

action="$1";
shift;

if [[ "$1" != "" ]]; then
	for a in "$@"; do
		echo "Action is: $action";
		case "$action" in
			stop|start|reload)
				${action}_${a}
			;;
			restart)
				"stop_${a}";
				"start_${a}";
			;;
			"*")
				echo "invalid action: $action";
				exit 1
		esac
	done
else
	$action;
fi

