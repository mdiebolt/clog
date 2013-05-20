assert = require 'assert'

{clog} = require '../lib/clog'
{nodes} = require 'coffee-script'

isNumber = (number) ->
  Object::toString.call(number) is '[object Number]'

describe 'Clog', ->
  describe '#churn', ->
    it 'is defined', ->
      assert.ok clog.churn

    it 'counts the number of changes to the file', (done) ->
      clog.churn __filename, (err, output) ->
        assert.ok parseInt(output, 10) > 0

        done()

  describe '#nodes', ->
    it 'is defined', ->
      assert.ok clog.countNodes

    it 'counts nested nodes', ->
      output = clog.countNodes "#{__dirname}/fixtures/functions.coffee"

      assert.equal output, 3
