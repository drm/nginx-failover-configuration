docker network rm proxy-setup-test || true
docker network create --subnet=172.16.88.0/24 proxy-setup-test

dir=$(cd $(dirname "$0") && pwd);

docker rm -f proxy-setup-test--root 
docker rm -f proxy-setup-test--backend-1
docker rm -f proxy-setup-test--backend-2

docker run \
	-p 8080:8080 \
	-d \
	-v $dir/root.conf:/etc/nginx/conf.d/default.conf \
	--network proxy-setup-test \
	--ip=172.16.88.71 \
	--name=proxy-setup-test--root \
	nginx

docker run \
	-d \
	-v $dir/backend-1.conf:/etc/nginx/conf.d/default.conf \
	-v $dir/html/backend-1/:/var/www/html/ \
	--network proxy-setup-test \
	--ip=172.16.88.72 \
	--name=proxy-setup-test--backend-1 \
	nginx

docker run \
	-d \
	-v $dir/backend-2.conf:/etc/nginx/conf.d/default.conf \
	-v $dir/html/backend-2/:/var/www/html/ \
	--network proxy-setup-test \
	--ip=172.16.88.73 \
	--name=proxy-setup-test--backend-2 \
	nginx

