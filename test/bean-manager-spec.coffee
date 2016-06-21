{EventEmitter} = require 'events'
BeanManager = require '../src/bean-manager'

describe 'BeanManager', ->
  beforeEach ->
    @bean = new EventEmitter
    @bean._peripheral = {}
    @bean._peripheral.advertisement = localName: 'hello'
    @bean.connectAndSetup = sinon.stub().yields null
    @sut = new BeanManager
    @sut.BLEBean = {}
    {@BLEBean} = @sut
    @BLEBean.discover = sinon.stub().yields @bean

  afterEach (done) ->
    @sut.close done

  describe '->setup', ->
    context 'when starting for the first time', ->
      beforeEach (done) ->
        options =
          localName: 'hello'
        @sut.setup options, done

      it 'should connect to a bean', ->
        expect(@sut.bean).to.exist

    context 'when localName is the same', ->
      beforeEach (done) ->
        @sut.localName = 'hello'
        @sut.bean = @bean

        options =
          localName: 'hello'
        @sut.setup options, done

      it 'should connect to a bean', ->
        expect(@sut.bean).to.equal @bean

    context 'when localName is the has changed', ->
      beforeEach (done) ->
        @oldBean =
          _peripheral:
            advertisement:
              localName: 'oldBean'
          disconnect: sinon.stub().yields null
        @sut.localName = 'oldBean'
        @sut.bean = @oldBean

        options =
          localName: 'hello'

        @sut.setup options, done

      it 'should disconnect the old bean', ->
        expect(@oldBean.disconnect).to.have.been.called

      it 'should connect to a bean', ->
        expect(@sut.bean).to.equal @bean

  describe '->_initializeOnRssi', ->
    context 'when interval.rssi is set', ->
      beforeEach (done) ->
        @sut.emit = sinon.stub()
        options =
          localName: 'rssi'
          interval:
            rssi: 1
        @sut.setup options, done

      it 'should create @intervalPollForRssi', ->
        expect(@sut.intervalPollForRssi).to.exist

    context 'when interval.rssi is not set', ->
      beforeEach (done) ->
        options =
          localName: 'rssi'
        @sut.setup options, done

      it 'should not create an interval', ->
        expect(@sut.intervalPollForRssi).not.to.exist

  describe '->_initializeOnAccelerometer', ->
    context 'when interval.accelerometer is set', ->
      beforeEach (done) ->
        @sut.emit = sinon.stub()
        options =
          localName: 'accelerometer'
          interval:
            accelerometer: 1
        @sut.setup options, done

      beforeEach 'emitting accell', (done) ->
        @bean.once 'accell', => done()
        @bean.emit 'accell', 1, 2, 3

      it 'should call emit', ->
        data =
          accelerometer:
            x: 1
            y: 2
            z: 3
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when interval.accelerometer is not set', ->
      beforeEach (done) ->
        @sut.emit = sinon.stub()
        options =
          localName: 'accelerometer'
        @sut.setup options, done

      beforeEach 'emitting accell', (done) ->
        @bean.once 'accell', => done()
        @bean.emit 'accell', 1, 2, 3

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeOnTemperature', ->
    context 'when interval.temperature is set', ->
      beforeEach (done) ->
        @sut.emit = sinon.stub()
        options =
          localName: 'temperature'
          interval:
            temperature: 1
        @sut.setup options, done

      beforeEach 'emitting temp', (done) ->
        @bean.once 'temp', => done()
        @bean.emit 'temp', 90

      it 'should call emit', ->
        data =
          temperature:
            degrees: 90
            unit: 'Celsius'
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when interval.temperature is not set', ->
      beforeEach (done) ->
        @sut.emit = sinon.stub()
        options =
          localName: 'temperature'
        @sut.setup options, done

      beforeEach 'emitting temp', (done) ->
        @bean.once 'temp', => done()
        @bean.emit 'temp', 1, 2, 3

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeNotifyScratch scratch1', ->
    context 'when notify.scratch1 is set', ->
      beforeEach (done) ->
        @bean.notifyOne = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch1'
          notify:
            scratch1: true
        @sut.setup options, done

      it 'should call emit', ->
        data =
          scratch1: 0
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when notify.scratch1 is not set', ->
      beforeEach (done) ->
        @bean.notifyOne = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch1'
        @sut.setup options, done

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeNotifyScratch scratch2', ->
    context 'when notify.scratch2 is set', ->
      beforeEach (done) ->
        @bean.notifyTwo = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch2'
          notify:
            scratch2: true
        @sut.setup options, done

      it 'should call emit', ->
        data =
          scratch2: 0
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when notify.scratch2 is not set', ->
      beforeEach (done) ->
        @bean.notifyTwo = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch2'
        @sut.setup options, done

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeNotifyScratch scratch3', ->
    context 'when notify.scratch3 is set', ->
      beforeEach (done) ->
        @bean.notifyThree = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch3'
          notify:
            scratch3: true
        @sut.setup options, done

      it 'should call emit', ->
        data =
          scratch3: 0
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when notify.scratch3 is not set', ->
      beforeEach (done) ->
        @bean.notifyThree = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch3'
        @sut.setup options, done

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeNotifyScratch scratch4', ->
    context 'when notify.scratch4 is set', ->
      beforeEach (done) ->
        @bean.notifyFour = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch4'
          notify:
            scratch4: true
        @sut.setup options, done

      it 'should call emit', ->
        data =
          scratch4: 0
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when notify.scratch4 is not set', ->
      beforeEach (done) ->
        @bean.notifyFour = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch4'
        @sut.setup options, done

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->_initializeNotifyScratch scratch5', ->
    context 'when notify.scratch5 is set', ->
      beforeEach (done) ->
        @bean.notifyFive = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch5'
          notify:
            scratch5: true
        @sut.setup options, done

      it 'should call emit', ->
        data =
          scratch5: 0
        expect(@sut.emit).to.have.been.calledWith 'data', data

    context 'when notify.scratch5 is not set', ->
      beforeEach (done) ->
        @bean.notifyFive = sinon.stub().yields [0,0,0,0]
        @sut.emit = sinon.stub()
        options =
          localName: 'scratch5'
        @sut.setup options, done

      it 'should not call emit', ->
        expect(@sut.emit).not.to.have.been.called

  describe '->changeLight', ->
    beforeEach (done) ->
      @sut.setup {}, done

    beforeEach (done) ->
      @bean.setColor = sinon.stub().yields null
      @sut.changeLight 'white', done

    it 'should call bean.setColor', ->
      expect(@bean.setColor).to.have.been.called

  describe '->turnOff', ->
    beforeEach (done) ->
      @sut.setup {}, done

    beforeEach (done) ->
      @bean.setColor = sinon.stub().yields null
      @sut.turnOff done

    it 'should call bean.setColor', ->
      expect(@bean.setColor).to.have.been.called
