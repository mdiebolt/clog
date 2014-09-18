assert = require "assert"

{clog} = require "../lib/clog"

fixturePath = (name) ->
  "#{__dirname}/fixtures/#{name}.coffee"

describe "Clog", ->
  describe "churn", ->
    scores = JSON.parse clog.report [__filename]

    it "counts the number of changes to the file", ->
      assert.ok(scores[__filename].churn > 0)

  describe "#report", ->
    cases = fixturePath("case")
    ifs = fixturePath("nested_ifs")
    methods = fixturePath("methods")

    scores = JSON.parse clog.report [cases, ifs, methods]

    it "returns a list of methods", ->
      assert.ok(scores[methods].methods.length is 7)

    it "returns token compexity", ->
      assert.equal(scores[cases].complexity, 29)
      assert.equal(scores[ifs].complexity, 22)

    it "returns gpa", ->
      assert.equal(scores[cases].gpa.toFixed(2), 3.59)
      assert.equal(scores[ifs].gpa.toFixed(2), 3.27)

    it "returns token count", ->
      assert.equal(scores[cases].tokenCount, 26)
      assert.equal(scores[ifs].tokenCount, 18)
