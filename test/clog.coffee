assert = require 'assert'

{clog} = require '../lib/clog'
{nodes} = require 'coffee-script'

fixturePath = (name) ->
  "#{__dirname}/fixtures/#{name}"

describe 'Clog', ->
  describe '#churn', ->
    it 'is defined', ->
      assert.ok clog.churn

    it 'counts the number of changes to the file', (done) ->
      clog.churn __filename, (err, output) ->
        assert.ok parseInt(output, 10) > 0

        done()
