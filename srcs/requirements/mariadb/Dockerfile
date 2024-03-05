# Alpine Linux 3.18 버전을 베이스 이미지로 사용
FROM alpine:3.18

# Alpine 패키지 저장소를 업데이트하고, 시스템 업그레이드를 수행한 뒤,
# MariaDB 서버와 클라이언트, 그리고 dumb-init을 설치합니다.
# dumb-init은 단일 엔트리포인트를 제공하는 간단한 init 시스템으로, 
# 좀비 프로세스 수집 및 신호 전달과 같은 작업을 처리합니다.
RUN		apk update && apk upgrade &&\
		apk add mariadb mariadb-client dumb-init


# 호스트 머신의 현재 디렉토리 내 tools/mariadb.sh 파일을 
# 컨테이너의 /tmp/mariadb.sh로 복사합니다. 이 스크립트는 MariaDB 설정을 자동화합니다.
COPY		./tools/mariadb.sh /tmp/mariadb.sh

# 복사된 스크립트 파일에 실행 권한을 부여합니다.
RUN		chmod +x /tmp/mariadb.sh

# MariaDB 데이터를 저장할 디렉토리를 생성하고,
# mysql 사용자 및 그룹에게 소유권을 부여합니다.
RUN       	mkdir -p /run/mysqld
RUN       	chown -R mysql:mysql /run/mysqld

# 컨테이너의 건강 상태를 확인하기 위한 HEALTHCHECK 명령어를 설정합니다.
# 30초 간격으로 mysqladmin ping 명령어를 실행하여 MariaDB 서버의 응답을 확인합니다.
# 시작 대기 시간은 5초, 타임아웃은 30초로 설정하며, 3회 재시도 후에도 실패하면 unhealthy 상태로 판단합니다.
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "mysqladmin", "ping" ]

# Run MariaDB configuration script as entry point
# ENTRYPOINT	[ "sh", "/tmp/mariadb.sh" ]
# 컨테이너가 시작될 때 실행될 엔트리포인트를 설정합니다.
# dumb-init을 사용하여 /tmp/mariadb.sh 스크립트를 실행합니다.
# 이렇게 설정함으로써, MariaDB 프로세스의 올바른 시작과 종료, 신호 처리를 보장합니다.
ENTRYPOINT	[ "dumb-init", "--", "sh", "/tmp/mariadb.sh" ]
