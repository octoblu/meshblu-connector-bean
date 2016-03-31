describe 'Bean', ->
  it 'should start', ->
    Bean = require('../')
    expect(new Bean().start({}))
