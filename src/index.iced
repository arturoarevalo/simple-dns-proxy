options = require "yargs"
    .usage """
        Usage: simple-dns-proxy <dns-record> [-u <upstream server>] [-p <port>]

        DESCRIPTION
            A simple DNS proxy which allows to locally resolve some domain names or patterns and forward the rest of them to an upstream, real DNS server.

        SECURITY
            By default, it tries to bind to the standard DNS port (53). If you run it under the root account, additional security can be obtained using the -U and -G options.
        """
    .command "dns-record", "DNS record to resolve"
    .option "u", { alias: "upstream", demand: false, requiresArg: true, describe: "Upstream DNS server to send requests to", default: "8.8.8.8"}
    .option "p", { alias: "port", demand: false, requiresArg: true, describe: "Port to bind the DNS service", default: 53}
    .option "a", { alias: "admin-port", demand: false, requiresArg: true, describe: "Port to bind the HTTP administation interface (0 = disabled)", default: 5380}
    .option "U", { alias: "uid", demand:false, requiresArg: true, describe: "uid/username to set upon execution" }
    .option "G", { alias: "gid", demand:false, requiresArg: true, describe: "gid/groupname to set upon execution" }
    .help "?"
    .alias "?", "help"
    .example "simple-dns-proxy www.test.com:A:127.0.0.1", "Resolve www.test.com to 127.0.0.1"
    .example "simple-dns-proxy *.test.com:A:127.0.0.1", "Resolve *.test.com to 127.0.0.1"
    .epilog "Copyright 2015 Arturo Arévalo"
    .argv




DnsServer = require "./dns-server"
dnsServer = new DnsServer options

dnsServer.addTextEntry entry for entry in options._

dnsServer.start()