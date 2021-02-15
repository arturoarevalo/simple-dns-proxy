logger = require "winston-color"
recordTable = require "./record-table"

class EntryList

    constructor: ->
        @entries = []

    addEntry: (domain, type = "A", address = "127.0.0.1", ttl = 1800) ->
        try
            d = "^" + domain.replace(/\*/g, "\\S+").replace(/\./g, "\\.") + "$"

            @entries.push
                domain: domain,
                domainRegex: new RegExp(d, "i"),
                type: type,
                address: address,
                ttl: ttl

            logger.info "added domain", domain, "type", type, "address", address, "ttl", ttl, "to the local resolution entry list"

        catch error
            logger.error error

    addTextEntry: (data) ->
        try
            parts = data.split ":"
            @addEntry parts[0], parts[1], parts[2]

        catch error
            logger.error "could not parse DNS record", data, error

    findEntries: (name, type) ->
        (entry for entry in @entries when ((entry.domainRegex.exec name) and (recordTable[entry.type] is type)))

module.exports = EntryList
