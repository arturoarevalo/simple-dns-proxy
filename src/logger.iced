Winston = require "winston"

# create logger
logger = new Winston.Logger
    transports: [
        new Winston.transports.Console
            level: "debug",
            handleExceptions: true,
            json: false,
            colorize: true
    ]


module.exports = logger