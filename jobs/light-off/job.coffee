http = require 'http'

class LightOff
  constructor: ({@connector}) ->
    throw new Error 'LightOff requires connector' unless @connector?

  do: (message, callback) =>
    @connector.turnLightOff callback

module.exports = LightOff
