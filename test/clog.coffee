assert = require 'assert'

{clog} = require '../lib/clog'
{nodes} = require 'coffee-script'

isNumber = (number) ->
  Object::toString.call(number) is '[object Number]'

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

  describe '#countNodes', ->
    it 'is defined', ->
      assert.ok clog.countNodes

    it 'counts nested nodes', ->
      output = clog.countNodes fixturePath("functions.coffee")

      assert.equal output, 3

  describe '#methods', ->
    it 'is defined', ->
      assert.ok clog.methods

    it 'handles functions assigned to variables', ->
      output = clog.methods fixturePath("functions.coffee")

      assert.equal output.someFn, 1
      assert.equal output.anotherFn, 1
      assert.equal output.thirdFn, 1

    it 'handles nested function assignments', ->
      output = clog.methods fixturePath("nested_functions.coffee")

      assert.equal output.aFn, 11

      # TODO fix nested functions. The
      # parser shows them ending on the
      # line after their last statement
      assert.equal output.nestedFn, 9
      assert.equal output.superNestedFn, 5

    it 'handles functions in an object literal', ->
      output = clog.methods fixturePath("object_literal_functions.coffee")

      assert.equal output.shortFn, 1
      assert.equal output.mediumFn, 3
      assert.equal output.longFn, 6

    it 'handles anonymous functions', ->
      output = clog.methods fixturePath("anonymous_functions.coffee")

      # output numbers anonymous functions
      # because there isn't another way to
      # keep track of them
      assert.equal output.anonymous1, 3

    it 'handles methods on CoffeeScript classes', ->
      output = clog.methods fixturePath("coffeescript_class.coffee")

      assert.equal output.initialize, 2
      assert.equal output.honk, 1
      assert.equal output.drive, 2
      assert.equal output.accelerate, 3
