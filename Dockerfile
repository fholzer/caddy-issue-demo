FROM alpine:3.6

ENV CADDY_VERSION=v0.10.12
ENV EASYRSA_VERSION=3.0.4

RUN apk update && \
	apk add wget curl tar gzip openssl && \
	mkdir /opt/ && \
	cd /opt && \
	wget https://github.com/mholt/caddy/releases/download/${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz -O caddy.tar.gz && \
	mkdir caddy && \
	cd caddy && \
	tar xf ../caddy.tar.gz && \
	cd /opt && \
	wget https://github.com/OpenVPN/easy-rsa/releases/download/v$EASYRSA_VERSION/EasyRSA-$EASYRSA_VERSION.tgz -O easyrsa.tgz && \
	tar xf easyrsa.tgz && \
	mv EasyRSA-$EASYRSA_VERSION easyrsa && \
	cd easyrsa && \
	./easyrsa init-pki && \
	./easyrsa --batch build-ca nopass && \
	./easyrsa --batch build-server-full unprotected.example.com nopass && \
	./easyrsa --batch build-server-full protected.example.com nopass && \
	mkdir -p /srv/www/htdocs/protected /srv/www/htdocs/unprotected && \
	echo "this file is protected by a client certificate" >/srv/www/htdocs/protected/index.txt && \
	echo "everyone can see this file" >/srv/www/htdocs/unprotected/index.txt

CMD ["sh", "/opt/caddy/runTests.sh"]
WORKDIR /opt/caddy
ADD . /opt/caddy
