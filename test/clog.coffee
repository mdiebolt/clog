assert = require "assert"

{clog} = require "../lib/clog"

fixturePath = (name) ->
  "#{__dirname}/fixtures/#{name}.coffee"

describe "Clog", ->
  describe "#churn", ->
    it "counts the number of changes to the file", ->
      assert.ok(clog.churn(__filename) > 0)

  describe "#score", ->
    describe "files with switch statements", ->
      it "scores properly", ->
        assert.equal(clog.score(fixturePath("case")), 29)

  describe "#report", ->
    cases = fixturePath("case")
    ifs = fixturePath("nested_ifs")

    scores = JSON.parse clog.report([cases, ifs])

    it "returns token scores", ->
      assert.equal(scores[cases].complexity, 29)
      assert.equal(scores[ifs].complexity, 22)

    it "returns average complexity", ->
      assert.equal(scores[cases].averageComplexity.toFixed(2), 1.12)
      assert.equal(scores[ifs].averageComplexity.toFixed(2), 1.22)

    it "returns token count", ->
      assert.equal(scores[cases].tokenCount, 26)
      assert.equal(scores[ifs].tokenCount, 18)
