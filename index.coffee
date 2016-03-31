{EventEmitter2} = require 'eventemitter2'
SCHEMA          = require './schema'
tinycolor       = require 'tinycolor2'
BLEBean         = require '@octoblu/ble-bean'
_               = require 'lodash'
debug           = require('debug')('meshblu-connector-bean:index')

class Bean extends EventEmitter2
  constructor: ->
    debug 'Bean constructed'

  start: (device) =>
    @emit 'update', SCHEMA
    @setOptions device.options

  didBeanChange: (bean) =>
    return false unless bean?
    return bean._peripheral.advertisement.localName == @options.localName

  getBean: (callback=->) =>
    return callback(null, @_bean) if @didBeanChange(@_bean)
    BLEBean.is = (peripheral) =>
      peripheral.advertisement.localName == @options.localName

    BLEBean.discover (bean) =>
      bean.connectAndSetup =>
        @_bean = bean
        callback(null, bean)

  onMessage: (message) =>
    debug 'onMessage', message
    @updateBean message.payload

  onConfig: (device) =>
    debug 'onConfig', device.options
    @setOptions device.options

  setOptions: (@options={}) =>
    debug 'setOptions', @options
    @disconnectBean() if @_oldBeanName == @options.localName
    @_oldBeanName = @options.localName
    @setupBean()

  disconnectBean:  =>
    return unless @_bean?
    @_bean.disconnect =>
    @_bean = null

  pollForRssi: (bean) =>
    clearInterval @_pollForRssiInterval
    @_pollForRssiInterval = setInterval =>
      bean._peripheral.updateRssi (error, rssi) =>
        data = rssi: rssi
        debug 'rssi data', data
        @sendMessage data
    , @options.broadcastRSSIInterval

  pollForAccell: (bean) =>
    bean.on 'accell', (x, y, z, valid) =>
      data =
        accell:
          x: parseFloat x
          y: parseFloat y
          z: parseFloat z
      debug 'accel data', data
      @sendMessage data
    requestAccell = _.bind bean.requestAccell, bean
    clearInterval @_pollForAccellInterval
    @_pollForAccellInterval = setInterval requestAccell, @options.broadcastAccelInterval

  pollForTemp: (bean) =>
    bean.on 'temp', (temp, valid) =>
      data = temp: temp
      debug 'temp data', data
      @sendMessage data

    requestTemp = _.bind bean.requestTemp, bean
    clearInterval @_pollForTempInterval
    @_pollForTempInterval = setInterval requestTemp, @options.broadcastTempInterval

  notifyScratch: (key, scratchFunc) =>
    scratchFunc (data) =>
      buffer = new Buffer [data['0'], data['1'], data['2'], data['3']]
      data = {}
      data[key] = buffer.readInt32LE 0
      @sendMessage data
    , _.noop

  sendMessage: (data) =>
    @emit 'message',
      devices: ['*']
      payload: data

  setupBean: =>
    return unless @options.localName?

    @getBean (error, bean) =>
      return @emit 'error', error if error?

      @pollForRssi bean if @options.broadcastRSSI
      @pollForAccell bean if @options.broadcastAccel
      @pollForTemp bean if @options.broadcastTemp
      @notifyScratch 'scratch1', bean.notifyOne   if @options.notifyScratch1
      @notifyScratch 'scratch2', bean.notifyTwo   if @options.notifyScratch2
      @notifyScratch 'scratch3', bean.notifyThree if @options.notifyScratch3
      @notifyScratch 'scratch4', bean.notifyFour  if @options.notifyScratch4
      @notifyScratch 'scratch5', bean.notifyFive  if @options.notifyScratch5

      @setBeanColor bean, 'blue'
      _.delay @setBeanColor, 2000, bean, 'black'

  updateBean: (payload={}) =>
    @getBean (error, bean) =>
      return @emit 'error', error if error?
      color = 'black'
      color = payload.color if payload.on
      @setBeanColor bean, color

  setBeanColor: (bean, color) =>
    rgb = tinycolor(color).toRgb();
    bean.setColor new Buffer([rgb.r, rgb.g, rgb.b]), _.noop

module.exports = Bean
