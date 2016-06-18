{job} = require '../../jobs/light-off'

describe 'LightOff', ->
  context 'when given a valid message', ->
    beforeEach (done) ->
      @connector =
        turnLightOff: sinon.stub().yields null
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.turnLightOff', ->
      expect(@connector.turnLightOff).to.have.been.called
