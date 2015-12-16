simple-dns-proxy
================

Description
-----------

`simple-dns-proxy` is very simple tool that sets up a DNS server that will provide
customized responses to certain queries while letting the rest go through an upstream
DNS server, this is, acting like a proxy.

This can be useful when you don't have access to the DNS records for a domain or just
want to fake the response for testing purposes.

For instance, imagine you're developing an application that allows registered users to
have their own subdomain on your site, something like `<username>.my-app.com`. You can
easily test this scenario on your development machine using `simple-dns-proxy`:

    simple-dns-proxy *.my-app.com:A:127.0.0.1


Installation
------------

    npm install -g simple-dns-proxy

Usage
-----

    simple-dns-proxy *.mydomain.com:A:127.0.0.1 -u 8.8.8.8

The above will run a DNS server listening on UDP port 53 (the default DNS service port)
that will resolve `A` queries for ANY subdomain of the domain `mydomain.com` with the IP
address `127.0.0.1`. Any other request will be forwarded to the upstream server at `8.8.8.8`.

More than one rule can be defined, just separate them using whitespaces, like so:

    simple-dns-proxy test-*.domain.com:A:10.0.0.1 prod-*.domain.com:A:10.0.0.2

Also, any valid DNS record type can be used:

    simple-dns-proxy my-secret-domain.com:MX:192.168.1.100

Security
--------

By default `simple-dns-proxy` will try to bind to the standard DNS port (UDP 53). Depending on
your configuration this will fail. First, you may need to run it with elevated privileges, in
Windows, or as a superuser, in linux based systems:

    sudo simple-dns-proxy ...

Second, it may fail if you already have any other piece of software listening at that port. This
can be the case, for instance, for Ubuntu based systems, which use `dnsmasq`. You can take rid
of this by editing the `/etc/NetworkManager/NetworkManager.conf` file, commenting out the
`dns=dnsmasq` line and restarting the network manager service (`sudo service network-manager restart`).

Note that if you're running `simple-dns-proxy` as a superuser you may be also interested in using the
`-G <group id/group name>` and `-U <user id/user name>` parameters to force it use a different
account after initialization.
