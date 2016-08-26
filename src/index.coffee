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
    { localName, interval, notify } = @options
    interval = @_checkEnabledIntervals interval unless !interval?
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

  _checkEnabledIntervals: (interval) =>
    { accel_enable, temp_enable, rssi_enable } = interval
    interval.accelerometer = 0 if accel_enable == false && accel_enable?
    interval.temperature = 0 if temp_enable == false && temp_enable?
    interval.rssi = 0 if rssi_enable == false && rssi_enable?
    return interval

module.exports = Connector
