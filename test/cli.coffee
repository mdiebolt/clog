assert = require "assert"
cli = require "../lib/cli"

describe "CLI", ->
  describe "options", ->
    it "outputs usage instructions", ->
      output = cli
        _: []

      assert.ok(output.indexOf("Usage:") >= 0)

    it "outputs version", ->
      output = cli
        _: []
        v: true

      assert.ok(output.indexOf("0.0.12") >= 0)

  describe "reporting on directories", ->
    it "supports passing in a directory", ->
      output = cli
        _: ["test"]

      assert.ok(output.length)

    xit "supports passing in the current directory", ->
      output = JSON.parse(cli({_: ["."]}))

      assert.ok(output["./source/clog.coffee"].churn?)
      assert.ok(output["./test/clog.coffee"].tokenCount?)

  describe "reporting on files", ->
    it "supports passing in a single file", ->
      report = cli
        _: ["test/fixtures/case.coffee"]

      output = JSON.parse(report)
      assert.ok(output["test/fixtures/case.coffee"].cyclomaticComplexity?)

    it "supports passing in multiple files", ->
      report = cli
        _: ["test/fixtures/nested_ifs.coffee", "source/rules.coffee"]

      output = JSON.parse(report)
      assert.ok(output["test/fixtures/nested_ifs.coffee"].gpa?)
      assert.ok(output["source/rules.coffee"].churn?)

    it "supports passing in a mix of directories and files", ->
      report = cli
        _: ["source", "test/cli.coffee"]

      output = JSON.parse(report)
      assert.ok(output["source/rules.coffee"].gpa?)
      assert.ok(output["source/clog.coffee"].gpa?)
      assert.ok(output["test/cli.coffee"].churn?)
