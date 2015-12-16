logger = require "./logger"

dns = require "native-dns"
async = require "async"

EntryList = require "./entrylist"


class DnsServer

    constructor: (options) ->
        @port = options.port or 53
        @gid = options.gid
        @uid = options.uid

        @server = dns.createServer()
        @entries = new EntryList
        @authority =
            address: options.upstream or "8.8.8.8",
            port: 53,
            type: "udp"

        @server.on "listening", =>
            logger.info "dns server listening on", @server.address()

        @server.on "close", =>
            logger.info "dns server closed"

        @server.on "error", (err, buff, req, res) =>
            logger.error err.stack

        @server.on "socketError", (err, socket) =>
            logger.error err

        @server.on "request", (req, res) => @handleRequest req, res


    start: ->
        @server.serve @port
        @secure()


    secure: ->
        if process.getuid() is 0
            if @gid
                logger.info "setting gid to", @gid
                process.setgid @gid

            if @uid
                logger.info "setting uid to", @uid
                process.setuid @uid


    addEntry: (domain, type = "A", address = "127.0.0.1", ttl = 1800) ->
        @entries.addEntry domain, type, address, ttl


    addTextEntry: (data) ->
        @entries.addTextEntry data


    proxyQuestion: (question, response, callback) ->
        request = dns.Request
            question: question,
            server: @authority,
            timeout: 1000

        request.on "message", (err, msg) =>
            response.answer.push answer for answer in msg.answer

        request.on "end", callback

        request.send()


    handleRequest: (request, response) ->
        f = []

        # proxy all questions
        # since proxying is asynchronous, store all callbacks

        for question in request.question

            entries = @entries.findEntries question.name
            if entries.length
                for entry in entries
                    record =
                        name: question.name,
                        type: entry.type,
                        address: entry.address,
                        ttl: entry.ttl

                    logger.debug "resolving locally", record.name, "to", record.address
                    response.answer.push dns[record.type](record)
            else
                logger.debug "proxying", question.name, "to", @authority.address
                f.push (callback) => @proxyQuestion question, response, callback

        # do the proxying in parallel
        # when done, respond to the request by sending the response
        await async.parallel f, defer()

        response.send()


module.exports = DnsServer
