docker run -d --name haproxy --user root \
       -v /etc/haproxy:/usr/local/etc/haproxy:ro \
       --sysctl net.ipv4.ip_unprivileged_port_start=0 \
       -p 178.162.171.22:80:80 \
       -p 178.162.171.22:443:443 \
       -p 178.162.171.22:4244:4244 \
       -p 178.162.171.22:8404:8404 \
       haproxy:latest
