#!/bin/sh

# -> MySQL 소켓 파일 디렉토리 설정 
# 스크립트의 시작 부분에 /run/mysqld 디렉토리를 만들고, 그 권한을 MySQL 사용자와 그룹에게 할당하는 부분
# 이 디렉토리는 MySQL 소켓 파일을 저장하는 데 사용되며, 서버가 정상적으로 통신할 수 있도록 필요합니다.

# -> MariaDB 데이터베이스와 사용자를 설정하기 위한 명령어들을 담고 있는 /tmp/config.sql 파일을 생성합니다.
# MariaDB 데이터베이스 파일의 소유권을 설정하고, 데이터베이스 초기화를 수행합니다. 
# 이후 config.sql 파일에 데이터베이스와 사용자 설정 관련 SQL 명령어를 작성합니다.
	echo "MariaDB configuring."
	chown -R mysql:mysql /var/lib/mysql


# mysql_install_db 명령어는 MariaDB 데이터베이스 시스템 테이블을 초기화합니다.
# --basedir는 MariaDB 설치 경로를, --datadir는 데이터 파일을 저장할 디렉토리를 지정합니다.
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql > /dev/null
cat << EOF > /tmp/config.sql
	FLUSH PRIVILEGES;
	CREATE DATABASE IF NOT EXISTS $MARIADB_DB_NAME;
	CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PWD';
	CREATE USER IF NOT EXISTS '$MARIADB_USER'@'localhost' IDENTIFIED BY '$MARIADB_PWD';
	GRANT ALL PRIVILEGES ON wordpress.* TO '$MARIADB_USER'@'%';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PWD';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PWD';
	FLUSH PRIVILEGES;
EOF
	echo "MariaDB config.sql created."


# bootstrap mode : setting up mariadb without starting it.
# 부트스트랩 모드에서 mysqld를 실행하여 config.sql 파일에 저장된 SQL 명령어들을 처리합니다. 
# 이 과정을 통해 사용자와 데이터베이스가 설정됩니다. 설정이 완료되면 config.sql 파일을 삭제합니다.
	/usr/bin/mysqld --user=mysql --bootstrap < /tmp/config.sql
	rm -f /tmp/config.sql
	echo "MariaDB configured"


# connecting network from outside of container (listen)
# MariaDB 설정 파일을 수정하여 네트워킹을 활성화하고, 
# 외부에서의 접속을 허용하기 위해 bind-address를 모든 IP(0.0.0.0)로 설정합니다.
sed -i "s/skip-networking/# skip-networking/g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s/.*bind-address\s*=.*/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf


# mysqld_safe 스크립트를 사용하여 MariaDB 서버를 시작합니다. 
# 이 스크립트는 서버가 예기치 않게 종료될 경우 자동으로 재시작하는 등의 안전 조치를 제공합니다.
echo "MariaDB starting"
exec /usr/bin/mysqld_safe --user=mysql