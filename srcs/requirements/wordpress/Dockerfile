FROM	alpine:3.18

RUN		apk update && apk upgrade &&\
		apk add php81 php81-fpm php81-bcmath php81-cli \
			php81-curl php81-dom php81-exif php81-fileinfo \
			php81-iconv php81-intl php81-json php81-mbstring \
			php81-mysqli php81-mysqlnd php81-openssl \
			php81-phar php81-posix php81-gd php81-gmp \
			php81-shmop php81-simplexml php81-sockets php81-sodium \
			php81-xml php81-xmlreader php81-xmlwriter \
			php81-zip php81-zlib php81-pecl-imagick \
			mariadb-client curl dumb-init imagemagick
#https://make.wordpress.org/hosting/handbook/server-environment/

# making a group and user
RUN 	addgroup -g 9642 my_group && \
 		adduser -D -H -u 9646 -G my_group my_wpuser

# recommended setting
# PHP-FPM 설정 파일을 수정하여, 위에서 생성한 사용자 및 그룹(my_wpuser, my_group)을 사용하도록 합니다.
# 또한, PHP의 메모리 한도, 파일 업로드 크기 등을 조정하여 WordPress가 원활하게 실행될 수 있도록 최적화합니다.
RUN		sed -i 's/user =.*/user = my_wpuser/g' /etc/php81/php-fpm.d/www.conf ; \
		sed -i 's/group =.*/group = my_group/g' /etc/php81/php-fpm.d/www.conf ; \
		sed -i 's/;*listen =.*/listen = 9000/g' /etc/php81/php-fpm.d/www.conf ; \
		sed -i "s/;*memory_limit =.*/memory_limit = 512M/i" /etc/php81/php.ini ; \
		sed -i "s/;*upload_max_filesize =.*/upload_max_filesize = 64M/i" /etc/php81/php.ini ; \
		sed -i "s/;*max_file_uploads =.*/max_file_uploads = 200/i" /etc/php81/php.ini ; \
		sed -i "s/;*post_max_size =.*/post_max_size = 100M/i" /etc/php81/php.ini ; \
		sed -i "s/;*cgi.fix_pathinfo=.*/cgi.fix_pathinfo= 0/i" /etc/php81/php.ini ;
# https://wiki.alpinelinux.org/wiki/Nginx_with_PHP#PHP7_Installation
# cgi.fix_pathinfo=0 for security reason -> 
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/#passing-uncontrolled-requests-to-php

# some bug on wp-cli.phar :(
# "don't change it to wp", A colleague said.
# WP-CLI 도구를 다운로드하여 실행 가능하게 만들고, 시스템 전역에서 사용할 수 있도록 /usr/bin 디렉토리로 이동합니다. 
# WP-CLI는 WordPress 사이트를 관리하기 위한 명령줄 도구입니다.
RUN		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
		chmod +x wp-cli.phar && \
		mv wp-cli.phar /usr/bin/wp-cli.phar

# Wordpress configuration file
# 이전에 설명한 WordPress 설정 스크립트(wordpress_setting.sh)를 
# 이미지 내 /tmp 디렉토리로 복사하고 실행 가능하게 만듭니다.
COPY	./tools/wordpress_setting.sh /tmp/wordpress_setting.sh
RUN		chmod +x /tmp/wordpress_setting.sh
WORKDIR /var/www/html/

# ENTRYPOINT command will be executed when the container starts
ENTRYPOINT [ "dumb-init", "--", "sh", "/tmp/wordpress_setting.sh"]