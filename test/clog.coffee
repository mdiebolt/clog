assert = require "assert"

{clog} = require "../lib/clog"

fixturePath = (name) ->
  "#{__dirname}/fixtures/#{name}.coffee"

describe "churn", ->
  scores = null

  beforeEach ->
    scores = JSON.parse clog.report [__filename]

  it "counts the number of changes to the file", ->
    assert.ok(scores[__filename].churn > 0)

describe "classes", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("class")
    scores = JSON.parse clog.report [file]

  it "return correct report", ->
    assert.ok(scores[file].churn?)
    assert.equal(6, scores[file].tokenComplexity)
    assert.equal(2, scores[file].gpa.toFixed(2))
    assert.equal(3, scores[file].tokenCount)
    assert.equal("C", scores[file].letterGrade)

describe "nested if statements", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("nested_ifs")
    scores = JSON.parse clog.report [file]

  it "return correct report", ->
    assert.ok(scores[file].churn?)
    assert.equal(21, scores[file].tokenComplexity)
    assert.equal(3.43, scores[file].gpa.toFixed(2))
    assert.equal(18, scores[file].tokenCount)
    assert.equal("A", scores[file].letterGrade)

describe "case statements", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("case")
    scores = JSON.parse clog.report [file]

  it "return correct report", ->
    assert.ok(scores[file].churn?)
    assert.equal(scores[file].tokenComplexity, 26)
    assert.equal(scores[file].gpa.toFixed(2), 4)
    assert.equal(scores[file].tokenCount, 26)
    assert.equal(scores[file].letterGrade, "A")

describe "long files", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("long_file")
    scores = JSON.parse clog.report [file]

  it "correctly penalizes", ->
    assert.equal(scores[file].gpa.toFixed(2), 2.8, "GPA")

describe "complex files", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("complex")
    scores = JSON.parse clog.report [file]

  it "correctly penalizes", ->
    assert.equal(scores[file].gpa.toFixed(2), 2.3, "GPA")

describe "long function length", ->
  file = scores = null

  beforeEach ->
    file = fixturePath("long_function")
    scores = JSON.parse clog.report [file]

  it "correctly penalizes", ->
    assert.equal(scores[file].gpa.toFixed(2), 2.79, "GPA")
