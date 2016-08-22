Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    {@bean} = @sut
    @bean.turnLightOff = sinon.stub().yields null
    @bean.changeLight = sinon.stub().yields null
    @bean.setup = sinon.stub().yields null
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe '->on bean.data', ->
    beforeEach (done) ->
      options =
        localName: 'foo'
      @sut.start {options}, done

    beforeEach (done) ->
      @sut.emit = sinon.stub()
      data =
        foo: 'bar'
      @bean.once 'data', => done()
      @bean.emit 'data', data

    it 'should emit message', ->
      expect(@sut.emit).to.have.been.calledWith 'message', devices: ['*'], data: foo: 'bar'

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->turnLightOff', ->
    beforeEach (done) ->
      @sut.turnLightOff done

    it 'should call bean.turnLightOff', ->
      expect(@bean.turnLightOff).to.have.been.called

  describe '->changeLight', ->
    beforeEach (done) ->
      @sut.changeLight color: 'white', done

    it 'should call bean.changeLight', ->
      expect(@bean.changeLight).to.have.been.calledWith color: 'white'

  describe '->onConfig', ->
    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)
