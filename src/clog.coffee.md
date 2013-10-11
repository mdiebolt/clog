# Clog

A simple static analysis tool for CoffeeScript source code.
Leverages CoffeeScript compiler, walking over all tokens
in a file and weighting the code based on a number of heuristics
corresponding to the token type.

    execSync = require "execSync"
    {tokens} = require "coffee-script"

    fs = require "fs"

Rules for how each token type is weighted in terms of maintainability.

    SCORE_MAP =
      "+": 1
      "=": 1
      "BOOL": 1
      "IDENTIFIER": 1
      "->": 3
      "=>": 6
      "IF": 4
      "ELSE": 2
      "NUMBER": 1
      "(": 1
      ",": 1
      "-": 1
      ".": 2
      ":": 1
      "?": 3
      "?.": 5
      "@": 5
      "CALL_START": 2
      "CLASS": 30
      "COMPARE": 1
      "EXTENDS": 15
      "FOR": 10
      "FORIN": 10
      "FOROF": 10
      "INDENT": 1
      "INDEX_START": 2
      "LEADING_WHEN": 1
      "LOGIC": 1
      "MATH": 1
      "NULL": 3
      "PARAM_START": 3
      "REGEX": 10
      "RETURN": 0
      "STRING": 1
      "SUPER": 7
      "SWITCH": 7
      "TERMINATOR": 1
      "UNARY": 2
      "[": 2
      "{": 2

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

        sum + (SCORE_MAP[type] || 0)
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
