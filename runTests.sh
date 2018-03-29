#!/bin/sh
CACERT=/opt/easyrsa/pki/ca.crt

runTests() {
	echo -n "Should not require client authentication on unprotected vhost..."
	curl -s --cacert $CACERT --resolve unprotected.example.com:443:127.0.0.1 https://unprotected.example.com/ | grep -q "everyone" && echo "OK" || echo "FAILED"

	echo -n "Should require client authentication on protected vhost..."
	curl -s -f --cacert $CACERT --resolve protected.example.com:443:127.0.0.1 https://protected.example.com/ 1>/dev/null 2>&1
	[ "x$?" == "x35" ] && echo "OK" || echo "FAILED"

	echo -n "Should not reveal file of protected vhost when requesting from unprotected vhost..."
	curl -s --cacert $CACERT --resolve unprotected.example.com:443:127.0.0.1 https://unprotected.example.com/ -H "Host: protected.example.com" | grep -q "this file is protected by a client certificate" && echo "FAILED" || echo "OK"
}

echo
echo
echo Test tls client authentication
echo
echo Suite 1

# test 1
:> Caddyfile
cat Caddyfile.part.unprotected >> Caddyfile
cat Caddyfile.part.protected >> Caddyfile

# run server
./caddy -conf Caddyfile  &
CPID=$!
sleep 1
runTests
kill $CPID
sleep 1


echo
echo Suite 2

# test 2
:> Caddyfile
cat Caddyfile.part.protected >> Caddyfile
cat Caddyfile.part.unprotected >> Caddyfile

# run server
./caddy -conf Caddyfile  &
CPID=$!
sleep 1
runTests
kill $CPID
sleep 1
