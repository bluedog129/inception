FROM	alpine:3.18

RUN		apk update && apk upgrade && \
		apk add nginx openssl dumb-init

# Nginx 웹 서버와 SSL/TLS 인증서 저장을 위한 필요한 디렉토리를 생성합니다.
RUN		mkdir -p /var/www/html/
RUN 	mkdir -p /run/nginx
RUN 	mkdir -p /etc/nginx/ssl/

# 사용자 및 그룹을 추가하고, Nginx 설정 파일에서 사용자와 그룹을 기본값에서 
# 새로 생성한 my_nginxuser와 my_group으로 변경합니다.
RUN 	addgroup -g 9642 my_group && \
 		adduser -D -H -u 9650 -G my_group my_nginxuser && \
		sed -i 's/user nginx;/user my_nginxuser my_group;/g' /etc/nginx/nginx.conf

# Nginx가 사용할 디렉토리의 소유권을 새로 생성한 사용자와 그룹에 할당합니다.
RUN		chown -R my_nginxuser:my_group /run/nginx/ && \
		chown -R my_nginxuser:my_group /var/www/html/
# https://wiki.alpinelinux.org/wiki/Nginx

# 사용자 정의 Nginx 설정 파일을 컨테이너 내 /etc/nginx/http.d/ 디렉토리에 복사합니다. 
# 이 파일은 Nginx 서버의 동작을 구성합니다.
COPY	./conf/my.conf /etc/nginx/http.d/my.conf

# openssl 명령을 사용하여 자가 서명된 SSL/TLS 인증서를 생성합니다. 
# 인증서는 1년 동안 유효하며, 주요 정보(국가, 주/도, 조직 등)와 함께 서브젝트 대체 이름을 포함합니다.
RUN		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/hyojocho.key \
		-out /etc/nginx/ssl/hyojocho.crt \
		-subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Cadet/CN=hyojocho" \
		-addext 'subjectAltName=DNS:hyojocho.42.fr'
# https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm

# openssl 명령을 사용하여 자가 서명된 SSL/TLS 인증서를 생성
EXPOSE	443

# 컨테이너가 시작될 때 dumb-init을 사용하여 nginx를 포그라운드 모드(daemon off;)로 실행
ENTRYPOINT	[ "dumb-init", "--", "nginx", "-g", "daemon off;"]