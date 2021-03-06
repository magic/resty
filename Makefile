OUT_DIR = ./out
SRC_DIR = ./src
NGINX_SRC_DIR = ${SRC_DIR}/nginx
LUA_SRC_DIR = ${SRC_DIR}/lua
LIB_NAME = resty

.PHONY: \
	asset-build \
	nginx-build \
	docker-build \
	docker-run \
	docker-rm \
	docker-rm-containers \
	docker-rm-images \
	docker-connect \
	build \
	moon-build \
	moon-watch \
	moon-lint \
	server-dev \
	server-production \
	clean \
	all \
	help

all: build run

asset-build:
	@mkdir -p ${OUT_DIR}
	@cp -r ${SRC_DIR}/assets/ ${OUT_DIR}

nginx-build:
	@mkdir -p ${OUT_DIR}/
	@cp -r ${NGINX_SRC_DIR}/* ${OUT_DIR}/

moon-build:
	@mkdir -p ${OUT_DIR};
	@cd ${LUA_SRC_DIR} && moonc \
		-t ../../${OUT_DIR}/ \
		./*

moon-watch:
	@moonc \
		-w src/* \
		-o ${OUT_DIR}/${LIB_NAME}.lua \
		${LUA_SRC_DIR}/${LIB_NAME}.moon

moon-lint:
	@moonc -l ${LUA_SRC_DIR}/*

docker-build:
	@docker build -t="magic/${LIB_NAME}" .

docker-run:
	@docker run \
		--name ${LIB_NAME} \
		--rm \
		magic/${LIB_NAME} \
		lapis server production

run: docker-run

# removes ALL docker containers
docker-rm-containers:
	@containers=$(shell docker ps -a -q)
ifneq (${containers}"t","t")
	echo "removing containers ${containers}" && \
	docker rm ${containers}
endif

# removes ALL docker images
docker-rm-images:
	@docker rmi $(shell docker images -q)

docker-connect:
	@docker run -it magic/${LIB_NAME} sh

docker-rm:
	@docker rm -f resty

# start lua lapis server in development mode
server: build-source
	@cd out && sudo lapis server development

# start lua lapis server in production mode
server-production:
	@cd out && sudo lapis server production

build-source: asset-build nginx-build moon-build
build: build-source docker-build

clean:
	@rm -fr \
		${OUT_DIR}
	@echo "removed ./out"

help:
	@echo "\
make: \n\
all - build, then run \n\
build - build nginx and lua, then build docker container\n\
docker-run - runs the prebuilt docker container \n\
clean - removes the out directory \n\
\n\
\n\
asset-build - copy static files \n\
nginx-build - build nginx config files to OUT_DIR/nginx \n\
moon-build - build moonscript to OUT_DIR/lua \n\
docker-build - build docker container based on files in out \n\
docker-rm - remove the resty container \n\
docker-rm-containers - remove all docker containers \n\
docker-rm-images - remove all docker images \n\
docker-connect - connect to the docker container \n\
moon-watch - watch changes to moon files and recompile out directory on changes \n\
server-dev - starts a lapis server in development mode (not implemented yet) \n\
server-production - starts a lapis server in production mode (not implemented yet) \n\
lint - lints the moonscript sources \n\
"
