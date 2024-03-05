#!/bin/sh

echo "Checking mariadb connection"

# try to access to mariadb -> it fails until mariadb is ready.
# this command will log into wordpress database.
# every mariadb configuration has done before turning mariadb on
# -> mariadb setting is done before booting it up,
# -> with bootstrap mode!

while ! mariadb -h${MARIADB_HOST_NAME} -u${MARIADB_USER} -p${MARIADB_PWD} ${MARIADB_DB_NAME}
do
    sleep 2;
done
echo "MariaDB connected"

if [ -f /var/www/html/wp-config.php ]
then
	echo "Wordpress already configured."
else

# https://make.wordpress.org/cli/handbook/how-to/how-to-install/
# 이 코드 스니펫은 WP-CLI 도구를 사용하여 WordPress 사이트를 설정하는 과정을 설명합니다

# WP-CLI 업데이트
 	wp-cli.phar cli update --yes --allow-root

# WordPress 다운로드:
	wp-cli.phar core download --allow-root --version=6.3.2 --path=/var/www/html

# WordPress 설정 파일 생성
	wp-cli.phar config create --allow-root \
			--dbname=${MARIADB_DB_NAME} \
			--dbuser=${MARIADB_USER} \
			--dbpass=${MARIADB_PWD} \
			--dbhost=${MARIADB_HOST_NAME} \
			--path=/var/www/html/ 

# WordPress 설치
	wp-cli.phar core install --allow-root \
			--url=${WP_URL} \
			--title=${WP_TITLE} \
			--admin_user=${WP_ADMIN_USER} \
			--admin_password=${WP_ADMIN_PWD} \
			--admin_email=${WP_ADMIN_EMAIL} \
			--path=/var/www/html/

# 새 WordPress 사용자 생성
	wp-cli.phar user create --allow-root \
			${WP_USER} ${WP_USER_EMAIL} \
			--user_pass=${WP_USER_PWD} \
			--role=administrator \
			--display_name=${WP_USER} \
			--path=/var/www/html/

	# /usr/bin/wp-cli.phar plugin install classic-editor --activate --allow-root
	# /usr/bin/wp-cli.phar plugin install really-simple-ssl --activate --allow-root

	#  Docker 컨테이너 내에서 WordPress 설치 디렉토리의 소유권과 권한을 설정하는 과정
	
	chown -R my_wpuser:my_group /var/www/html/
	find /var/www/html -type d -exec chmod 755 {} \;
	find /var/www/html -type f -exec chmod 644 {} \;
	find /var/www/html/wp-content -type d -exec chmod 775 {} \;
	find /var/www/html/wp-content -type f -exec chmod 664 {} \;

	chown my_wpuser:my_group /var/www/html/wp-content/uploads
	chmod 775 /var/www/html/wp-content

	echo "Wordpress configured"
fi

echo "Wordpress ready"
exec /usr/sbin/php-fpm81 --nodaemonize