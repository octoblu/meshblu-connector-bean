http = require 'http'

class ChangeLight
  constructor: ({@connector}) ->
    throw new Error 'ChangeLight requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.color is required') unless data?.color?

    {color} = data

    @connector.changeLight {color}, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = ChangeLight
