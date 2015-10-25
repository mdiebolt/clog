assert = require "assert"

{clog} = require "../lib/clog"

fixturePath = (name) ->
  "#{__dirname}/fixtures/#{name}.coffee"

describe "Clog", ->
  describe "churn", ->
    scores = null

    beforeEach ->
      scores = JSON.parse clog.report [__filename]

    it "counts the number of changes to the file", ->
      assert.ok(scores[__filename].churn > 0)

  describe "#report", ->
    cases = ifs = klass = scores = null

    beforeEach ->
      cases = fixturePath("case")
      ifs = fixturePath("nested_ifs")
      klass = fixturePath("class")

      scores = JSON.parse clog.report [cases, ifs, klass]

    it "returns churn", ->
      assert.ok(scores[cases].churn?)
      assert.ok(scores[ifs].churn?)
      assert.ok(scores[klass].churn?)

    it "returns token compexity", ->
      assert.equal(scores[cases].tokenComplexity, 26)
      assert.equal(scores[ifs].tokenComplexity, 21)
      assert.equal(scores[klass].tokenComplexity, 6)

    it "returns gpa", ->
      assert.equal(+scores[cases].gpa.toFixed(2), 4)
      assert.equal(+scores[ifs].gpa.toFixed(2), 3.43)
      assert.equal(+scores[klass].gpa.toFixed(2), 2)

    it "returns token count", ->
      assert.equal(scores[cases].tokenCount, 26)
      assert.equal(scores[ifs].tokenCount, 18)
      assert.equal(scores[klass].tokenCount, 3)

    it "returns letter grade", ->
      assert.equal(scores[cases].letterGrade, "A")
      assert.equal(scores[ifs].letterGrade, "A")
      assert.equal(scores[klass].letterGrade, "C")
