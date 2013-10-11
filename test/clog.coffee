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
    it "returns a hash of file names and their scores", ->
      cases = fixturePath("case")
      ifs = fixturePath("nested_ifs")

      scores = clog.report(cases, ifs)

      assert.equal(scores[cases], 29)
      assert.equal(scores[ifs], 22)