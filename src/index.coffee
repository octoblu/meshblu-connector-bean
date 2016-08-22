{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-bean:index')
BeanManager     = require './bean-manager'

class Connector extends EventEmitter
  constructor: ->
    @bean = new BeanManager

  isOnline: (callback) =>
    callback null, running: true

  changeLight: ({color}, callback) =>
    @bean.changeLight {color}, callback

  close: (callback) =>
    debug 'on close'
    @bean.close callback

  onConfig: (device={}, callback=->) =>
    { @options } = device
    @options ?= {}
    debug 'on config', @options
    {localName,interval,notify} = @options
    @bean.setup {localName, interval, notify}, (error) =>
      debug 'setup complete', error
      callback error

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback
    @bean.on 'data', (data) =>
      message =
         devices: ['*']
         data: data
      @emit 'message', message

  turnLightOff: (callback) =>
    @bean.turnLightOff callback

module.exports = Connector
