{EventEmitter}  = require 'events'
tinycolor       = require 'tinycolor2'
_               = require 'lodash'
async           = require 'async'
debug           = require('debug')('meshblu-connector-bean:bean-manager')
try
  unless process.env.SKIP_REQUIRE_BEAN == 'true'
    BLEBean = require '@octoblu/ble-bean'
catch error
  console.error error

class BeanManager extends EventEmitter
  constructor: ->
    @BLEBean = BLEBean

  changeLight: ({color}, callback) =>
    rgb = tinycolor(color).toRgb();
    @bean.setColor new Buffer([rgb.r, rgb.g, rgb.b]), callback

  _cleanupConnection: (callback) =>
    return callback() unless @bean?
    return callback() if @localName == @bean._peripheral.advertisement.localName
    @bean.disconnect callback
    @bean = null

  close: (callback) =>
    clearInterval @intervalPollForRssi
    callback()

  _connect: (callback) =>
    @BLEBean.is = (peripheral) =>
      peripheral.advertisement.localName == @localName

    @BLEBean.discover (@bean) =>
      @bean.connectAndSetup =>
        @_initialize callback

  _initialize: (callback) =>
    return callback new Error 'No Bean connected' unless @bean?
    tasks = [
      @_initializeOnRssi
      @_initializeOnAccelerometer
      @_initializeOnTemperature
      async.apply @_initializeNotifyScratch, 'scratch1', @bean.notifyOne
      async.apply @_initializeNotifyScratch, 'scratch2', @bean.notifyTwo
      async.apply @_initializeNotifyScratch, 'scratch3', @bean.notifyThree
      async.apply @_initializeNotifyScratch, 'scratch4', @bean.notifyFour
      async.apply @_initializeNotifyScratch, 'scratch5', @bean.notifyFive
    ]
    async.series tasks, callback

  _initializeOnRssi: (callback) =>
    clearInterval @intervalPollForRssi if @intervalPollForRssi?
    return callback() unless @interval?.rssi?
    return callback() unless @interval.rssi > 0
    @intervalPollForRssi = setInterval @_pollForRssi, @interval.rssi
    callback()

  _initializeOnAccelerometer: (callback) =>
    @bean.removeAllListeners 'accell'
    return callback() unless @interval?.accelerometer?
    return callback() unless @interval.accelerometer > 0
    @bean.on 'accell', _.throttle @_onAccelerometer, @interval.accelerometer, leading: true, trailing: false
    callback()

  _initializeOnTemperature: (callback) =>
    @bean.removeAllListeners 'temp'
    return callback() unless @interval?.temperature?
    return callback() unless @interval.temperature > 0
    @bean.on 'temp', _.throttle @_onTemperature, @interval.temperature, leading: true, trailing: false
    callback()

  _initializeNotifyScratch: (key, func, callback) =>
    return callback() unless func?
    func _.noop
    return callback() unless @notify?[key]
    func (data) =>
      buffer = new Buffer [data['0'], data['1'], data['2'], data['3']]
      data =
        "#{key}": buffer.readInt32LE 0
      @emit 'data', data
    , _.noop
    callback()

  _pollForRssi: =>
    return unless @bean?
    @bean._peripheral.updateRssi (error, rssi) =>
      return console.error error.stack if error?
      debug 'rssi data', {rssi}
      @emit 'data', {rssi}

  _onAccelerometer: (x, y, z)=>
    data =
      accelerometer:
        x: parseFloat x
        y: parseFloat y
        z: parseFloat z
    debug 'accel data', data
    @emit 'data', data

  _onTemperature: (temp)=>
    data =
      temperature:
        degrees: temp
        unit: 'Celsius'
    debug 'temp data', data
    @emit 'data', data

  setup: ({@localName,@interval,@notify}, callback) =>
    @_cleanupConnection (error) =>
      return callback error if error?
      @_connect callback

  turnOff: (callback) =>
    @changeLight color: 'black', callback

module.exports = BeanManager
