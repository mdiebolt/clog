assert = require 'assert'

{clog} = require '../lib/clog'

isNumber = (number) ->
  Object.prototype.toString.call(number) is '[object Number]'

describe 'Clog', ->
  describe '#churn', ->
    it 'is defined', ->
      assert.ok clog.churn

    it 'returns a number', ->
      output = clog.churn('./clog.coffee')

      assert.ok isNumber(output)
      assert.ok output > 0
