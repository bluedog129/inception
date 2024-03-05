# 사용자 변수 설정: 사용자 이름 
USER := hyojocho
# 데이터 경로
DATA_PATH := /home/${USER}/inception
# 컨테이너 이름
CONTAINERS := nginx wordpress mariadb
# 이미지 이름
IMAGES := nginx:inception wordpress:inception mariadb:inception
# 볼륨 이름
VOLUMES := srcs_mariadb-data srcs_wordpress-data
# 데이터베이스 데이터 경로
DB_DATAS := ${DATA_PATH}/mariadb-data ${DATA_PATH}/wordpress-data
# 네트워크 이름
NETWORKS := nginx-wordpress mariadb-wordpress
# 도커 컴포즈 파일 경로
DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml

# 'all' 타겟은 'up' 타겟을 기본 명령으로 설정합니다.
# 이는 'make'를 실행할 때 'make up'을 기본 동작으로 하게 합니다.
all : 
	make up

# 'up' 타겟은 프로젝트를 준비하고, 도커 컴포즈를 이용해 서비스를 빌드 및 백그라운드에서 실행합니다.
up :
	make prepare
	docker compose -f ${DOCKER_COMPOSE_FILE} up -d --build

# 'prepare' 타겟은 필요한 데이터 디렉토리를 생성합니다.
# wordpress와 mariadb 데이터를 저장할 디렉토리가 없으면 생성합니다.
prepare :
	@if [ ! -d "${DATA_PATH}/wordpress-data" ]; then \
		mkdir -p ${DATA_PATH}/wordpress-data; \
	fi
	@if [ ! -d "${DATA_PATH}/mariadb-data" ]; then \
		mkdir -p ${DATA_PATH}/mariadb-data; \
	fi


# 'start' 타겟은 도커 컴포즈를 이용해 모든 서비스를 시작합니다.
start :
	docker compose -f ${DOCKER_COMPOSE_FILE} start

# 'stop' 타겟은 도커 컴포즈를 이용해 모든 서비스를 중지합니다.
stop :
	docker compose -f ${DOCKER_COMPOSE_FILE} stop

# 'down' 타겟은 도커 컴포즈를 이용해 모든 서비스를 중지하고, 생성된 모든 리소스(네트워크, 볼륨 등)를 제거합니다.
down :
	docker compose -f ${DOCKER_COMPOSE_FILE} down

# 'clean' 타겟은 모든 컨테이너를 중지, 제거하고, 이미지, 볼륨, 네트워크를 제거합니다.
# 이 과정에서 발생할 수 있는 오류를 무시하기 위해 '-'를 사용합니다.
clean :
	-docker container stop ${CONTAINERS}
	-docker container rm ${CONTAINERS}
	-docker image rm ${IMAGES}
	-docker volume rm ${VOLUMES}
	-docker network rm ${NETWORKS}

# 'fclean' 타겟은 'clean' 타겟의 작업을 수행하며, 추가로 데이터 디렉토리를 강제로 삭제하고, 도커 시스템을 정리합니다.
fclean :
	-docker container stop ${CONTAINERS}
	-docker container rm ${CONTAINERS}
	-docker image rm ${IMAGES}
	-docker volume rm ${VOLUMES}
	-sudo rm -rf ${DB_DATAS}
	-docker network rm ${NETWORKS}
	-docker system prune -af

# 're' 타겟은 'fclean'을 수행하여 모든 것을 정리한 뒤, 'up' 타겟을 이용해 서비스를 다시 빌드 및 실행합니다.
re :
	make fclean
	make up
