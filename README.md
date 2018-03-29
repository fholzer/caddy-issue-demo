Run like so:

````
docker build -t caddy-test .
docker run -ti --rm caddy-test
````


For testing new caddy binaries run:
````
docker build -t caddy-test .
docker run -ti --rm -v /path/to/caddy:/opt/caddy/caddy caddy-test
````
