# Example
```
docker build -t owasp/modsecurity-crs .
docker run -p 80:80 -ti -e PARANOIA=5 --rm owasp/modsecurity-crs
```

or

```
docker build -t owasp/modsecurity-crs .
docker run -ti -p 80:80 -e PARANOIA=5 -e PROXY=1 --rm owasp/modsecurity-crs
```
# Environment Variables

The following environment variables are available to configure the CRS container:

| Name     | Description|
| -------- | ------------------------------------------------------------------- |
| PARANOIA | An integer indicating the paranoia level (Default: 1)               |
| PROXY    | An integer indicating if reverse proxy mode is enabled (Default: 0) |
| UPSTREAM | The IP Address (and optional port) of the upstream server when proxy mode is enabled. (Default: the container's default router, port 81) (Examples: 192.0.2.2 or 192.0.2.2:80) |

# Notes regarding reverse proxy

In order to more easily test drive the CRS ruleset, we include support for an technique called [Reverse Proxy](https://en.wikipedia.org/wiki/Reverse_proxy). Using this technique, you keep your pre-existing web server online at a non-standard host and port, and then configure the CRS container to accept public traffic. The CRS container then proxies the traffic to your pre-existing webserver. This way, you can test out CRS with any web server. Some notes:

* Proxy is not enabled by default. You'll need to pass the `-e PROXY=1` environment variable to enable it.
* You'll want to configure your typical webserver to listen on your docker interface only (i.e. 172.17.0.1:81) so that public traffic doesn't reach it.
* Do not use 127.0.0.1 as an UPSTREAM address. The loopback interface inside the docker container is not the same interface as the one on docker host.
* Note that traffic coming through this proxy will look like it's coming from the wrong address. You may want to configure your pre-existing webserver to use the `X-Forwarded-For` HTTP header to populate the remote address field for traffic from the proxy.
