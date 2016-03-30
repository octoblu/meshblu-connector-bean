packageJSON = require './package.json'

module.exports = {
  initializing: false
  currentVersion: packageJSON.version
  messageSchema:
    type: 'object'
    properties:
      color:
        type: 'string'
      on:
        type: 'boolean'
        required: false
  optionsSchema:
    type: 'object'
    properties:
      localName:
        type: 'string'
      broadcastAccel:
        type: 'boolean'
        default: false
      broadcastTemp:
        type: 'boolean'
        default: false
      broadcastRSSI:
        type: 'boolean'
        default: false
      notifyScratch1:
        type: 'boolean'
        default: false
      notifyScratch2:
        type: 'boolean'
        default: false
      notifyScratch3:
        type: 'boolean'
        default: false
      notifyScratch4:
        type: 'boolean'
        default: false
      notifyScratch5:
        type: 'boolean'
        default: false
      broadcastAccelInterval:
        type: 'integer'
        default: 5000
      broadcastTempInterval:
        type: 'integer'
        default: 5000
      broadcastRSSIInterval:
        type: 'integer'
        default: 5000
      timeout:
        type: 'integer'
        default: 30000
}
