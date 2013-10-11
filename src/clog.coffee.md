# Clog

A simple static analysis tool for CoffeeScript source code.
Leverages CoffeeScript compiler, walking over all tokens
in a file and weighting the code based on a number of heuristics
corresponding to the token type.

    execSync = require "execSync"
    {tokens} = require "coffee-script"
    {rules} = require "../lib/rules"

    fs = require "fs"

Helper to read a file in utf-8.

    read = (path) ->
      fs.readFileSync(path, "utf8")

## Metric: Churn

Indicates how many times a file has been changed. The more
it has been changed, the better a candidate it is for refactoring.

    churn = (filePath, cb) ->

Grep for commit since git whatchanged shows
multiple lines of details from each commit.

      output = execSync.exec "git whatchanged #{filePath} | grep 'commit' | wc -l"
      parseInt(output.stdout, 10)

## Metric: Token score

Determines how complex code is by weighting each token
based on maintainability. Using tokens is style agnostic
and won't change based on comment / documentation style,
or from personal whitespace style.

    score = (filePath) ->
      file = read(filePath)

      tokens(file).reduce (sum, token) ->
        type = token[0]

        sum + (rules[type] || 0)
      , 0

Output scores per file.

    report = (filePaths...) ->
      filePaths.reduce (hash, file) ->
        hash[file] = score(file)
        hash
      , {}

Export public API

    exports.clog =
      churn: churn
      score: score
      report: report
