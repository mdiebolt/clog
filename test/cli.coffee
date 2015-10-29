assert = require "assert"
{execSync} = require "child_process"

describe "options", ->
  it "outputs usage instructions", ->
    output = execSync "./bin/clog"

    assert.ok(output.toString("utf-8").indexOf("Usage:") >= 0)

  it "outputs version", ->
    output = execSync "./bin/clog -v"

    assert.ok(output.toString("utf-8").indexOf("0.0.12") >= 0)

describe "reporting on directories", ->
  it "supports passing in a directory", ->
    output = execSync "./bin/clog test"

    assert.ok(output.length > 0)

  xit "supports passing in the current directory", ->
    output = JSON.parse(execSync "./bin/clog .")

    assert.ok(output["./source/clog.coffee"].churn?)
    assert.ok(output["./test/clog.coffee"].tokenCount?)

describe "reporting on files", ->
  it "supports passing in a single file", ->
    output = JSON.parse(execSync "./bin/clog test/fixtures/case.coffee")

    assert.ok(output["test/fixtures/case.coffee"].cyclomaticComplexity?)

  it "supports passing in multiple files", ->
    command = "./bin/clog test/fixtures/nested_ifs.coffee source/rules.coffee"
    output = JSON.parse(execSync command)

    assert.ok(output["test/fixtures/nested_ifs.coffee"].gpa?)
    assert.ok(output["source/rules.coffee"].churn?)

  it "supports passing in a mix of directories and files", ->
    command = "./bin/clog source test/cli.coffee"
    output = JSON.parse(execSync command)
    assert.ok(output["source/rules.coffee"].gpa?)
    assert.ok(output["source/clog.coffee"].gpa?)
    assert.ok(output["test/cli.coffee"].churn?)
