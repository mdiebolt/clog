# Clog

A simple static analysis tool for CoffeeScript source code.
Leverages CoffeeScript compiler, walking over all tokens
in a file and weighing the code based on a number of heuristics
corresponding to the token type.

    {execSync} = require "child_process"
    {tokens} = require "coffee-script"
    rules = require "../lib/rules"

    fs = require "fs"
    glob = require "glob"

Helper to determine if filePath represents a literate Coffee file.

    isLiterate = (path) ->
      /\.litcoffee|\.coffee\.md/i.test(path)

Helper to return tokens for a given file path.

    tokensForFile = (path) ->
      file = fs.readFileSync(path, "utf8")

      tokens file,
        literate: isLiterate(path)

## Metric: Churn

Indicates how many times a file has been changed.
The more it has been changed, the better a candidate it is for refactoring.

    churn = (filePath) ->

Grep for commit since `git whatchanged` shows
multiple lines of details from each commit.

      command = "git whatchanged #{filePath} | grep 'commit' | wc -l"
      output = execSync command
      parseInt(output, 10)

## Metric: Token count

The number of tokens in the file.
Used in conjunction with token score to determine gpa.

    count = (filePath) ->
      tokensForFile(filePath).length

## Metric: Token complexity

Determines how complex code is by weighing each token based on maintainability.
Using tokens is style agnostic and won't change based on
comment / documentation style, or from personal whitespace style.

    complexity = (filePath) ->
      tokensForFile(filePath).reduce (sum, token) ->
        type = token[0]
        sum + (rules[type] || 0)
      , 0

## Metric: Complexity per token

Gives the file a grade based on it's token complexity compared to token length.
Scaled from 0-4.

    gpa = (filePath) ->
      tokenCount = count(filePath)
      return 0 if tokenCount is 0

      if 0 <= tokenCount <= 200
        longFilePenalty = 0
      else if 200 < tokenCount <= 300
        longFilePenalty = 0.25
      else if 300 < tokenCount <= 500
        longFilePenalty = 0.5
      else if tokenCount > 500
        longFilePenalty = 1

      base = tokenCount / complexity(filePath)
      penalized = (base * 4) - longFilePenalty

      Math.max(penalized, 0)

Return an array of CoffeeScript files based on file filePaths or directories
passed in.

    files = (paths) ->
      paths.reduce (list, path) ->
        stats = fs.lstatSync(path)

        if stats.isFile()
          list.push path
        else if stats.isDirectory()
          pattern = "#{path}/**/*\.+(coffee|coffee\.md|litcoffee)"
          list = list.concat(glob.sync pattern)

        list
      , []

Output scores per file.

    report = (filePaths, opts={}) ->
      scores = files(filePaths).reduce (hash, file) ->
        hash[file] =
          gpa: gpa(file)
          churn: churn(file)
          complexity: complexity(file)
          tokenCount: count(file)

        hash
      , {}

      JSON.stringify(scores, null, opts.indentSpace)

Export public API.

    exports.clog =
      report: report
      VERSION: "0.0.12"
