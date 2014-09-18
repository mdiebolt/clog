assert = require "assert"
execSync = require "exec-sync"

describe "cli", ->
  it "prints out usage instructions", ->
    output = execSync "./bin/clog"
    assert.ok(output.indexOf("Usage:") >= 0)

  describe "reports", ->
    it "supports passing in a directory", ->
      output = execSync "./bin/clog test"

      assert.ok(output.length > 0)

    it "supports passing in the current directory", ->
      output = JSON.parse(execSync "./bin/clog .")

      assert.ok(output["./source/clog.coffee.md"].churn?)
      assert.ok(output["./test/clog.coffee"].tokenCount?)

    it "supports passing in a single file", ->
      output = JSON.parse(execSync "./bin/clog test/fixtures/case.coffee")

      assert.ok(output["test/fixtures/case.coffee"].complexity?)

    it "supports passing in multiple files", ->
      command = "./bin/clog test/fixtures/nested_ifs.coffee source/rules.coffee.md"
      output = JSON.parse(execSync command)

      assert.ok(output["test/fixtures/nested_ifs.coffee"].gpa?)
      assert.ok(output["source/rules.coffee.md"].churn?)

    it "supports passing in a mix of directories and files", ->
      command = "./bin/clog source test/cli.coffee"
      output = JSON.parse(execSync command)

      assert.ok(output["source/rules.coffee.md"].gpa?)
      assert.ok(output["source/clog.coffee.md"].gpa?)
      assert.ok(output["test/cli.coffee"].churn?)
