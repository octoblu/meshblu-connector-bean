{job} = require '../../jobs/change-light'

describe 'ChangeLight', ->
  context 'when given a valid message', ->
    beforeEach (done) ->
      @connector =
        changeLight: sinon.stub().yields null
      message =
        data:
          color: 'hi'
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.changeLight', ->
      expect(@connector.changeLight).to.have.been.calledWith color: 'hi'

  context 'when given an invalid message', ->
    beforeEach (done) ->
      @connector = {}
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should error', ->
      expect(@error).to.exist
