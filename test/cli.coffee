assert = require "assert"
cli = require "../lib/cli"

SEMVER_PATTERN = /\d+\.\d+\.\d+/

describe "CLI", ->
  describe "instructions", ->
    it "outputs when no arguments are passed", ->
      output = cli
        _: []

      assert.ok(/Usage/.test(output))

  describe "help", ->
    it "outputs instructions with short flag", ->
      output = cli
        _: []
        h: true

      assert.ok(/Usage/.test(output))

    it "outputs instructions with short flag", ->
      output = cli
        _: []
        help: true

      assert.ok(/Usage/.test(output))

  describe "version", ->
    it "outputs version with short flag", ->
      output = cli
        _: []
        v: true

      assert.ok(SEMVER_PATTERN.test(output))

    it "outputs version with long flag", ->
      output = cli
        _: []
        version: true

      assert.ok(SEMVER_PATTERN.test(output))

  describe "reporting on directories", ->
    it "supports passing in a directory", ->
      output = cli
        _: ["test"]

      assert.ok(output.length)

  describe "reporting on files", ->
    it "supports passing in a single file", ->
      report = cli
        _: ["test/fixtures/case.coffee"]

      output = JSON.parse(report)
      assert.ok(output["test/fixtures/case.coffee"].gpa?)

    it "supports passing in multiple files", ->
      report = cli
        _: ["test/fixtures/nested_ifs.coffee", "source/rules.coffee"]

      output = JSON.parse(report)
      assert.ok(output["test/fixtures/nested_ifs.coffee"].gpa?)
      assert.ok(output["source/rules.coffee"].gpa?)

    it "supports passing in a mix of directories and files", ->
      report = cli
        _: ["source", "test/cli.coffee"]

      output = JSON.parse(report)
      assert.ok(output["source/rules.coffee"].gpa?)
      assert.ok(output["source/clog.coffee"].gpa?)
      assert.ok(output["test/cli.coffee"].gpa?)
