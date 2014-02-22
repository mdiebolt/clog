# Clog

A simple static analysis tool for CoffeeScript source code.
Leverages CoffeeScript compiler, walking over all tokens
in a file and weighing the code based on a number of heuristics
corresponding to the token type.

    execSync = require "exec-sync"
    {tokens} = require "coffee-script"
    {rules} = require "../lib/rules"

    fs = require "fs"
    glob = require "glob"

Helper to read a file in utf-8.

    read = (path) ->
      fs.readFileSync(path, "utf8")

Helper to determine if filePath represents
a literate Coffee file.

    isLiterate = (path) ->
      /\.litcoffee|\.coffee\.md/i.test(path)

## Metric: Churn

Indicates how many times a file has been changed. The more
it has been changed, the better a candidate it is for refactoring.

    churn = (filePath) ->

Grep for commit since git whatchanged shows
multiple lines of details from each commit.

      command = "git whatchanged #{filePath} | grep 'commit' | wc -l"
      output = execSync command
      parseInt(output, 10)

## Metric: Token count

The number of tokens in the file. Used in conjunction with
token score to determine average complexity per token.

    count = (filePath) ->
      file = read(filePath)

      tokens file,
        literate: isLiterate(filePath)
      .length

## Metric: Token score

Determines how complex code is by weighing each token
based on maintainability. Using tokens is style agnostic
and won't change based on comment / documentation style,
or from personal whitespace style.

    score = (filePath) ->
      file = read(filePath)

      tokens file,
        literate: isLiterate(filePath)
      .reduce (sum, token) ->
        type = token[0]
        sum + (rules[type] || 0)
      , 0

## Metric: Complexity per token

Represents the average complexity of each token in the file.

    averageComplexity = (filePath) ->
      tokenCount = count(filePath)
      return 0 if tokenCount is 0

      score(filePath) / tokenCount

Return an array of CoffeeScript files based on file filePaths
or directories passed in.

    files = (paths) ->
      paths.reduce (list, path) ->
        # get stats on the path in order to determine
        # if we have a directory or a file.
        stats = fs.lstatSync(path)

        if stats.isFile()
          list.push path
        else if stats.isDirectory()
          pattern = "#{path}/**/*\.+(coffee|coffee\.md|litcoffee)"
          list = list.concat(glob.sync pattern)

        list
      , []

Output scores per file.

    report = (filePaths) ->
      JSON.stringify(files(filePaths).reduce (hash, file) ->
        hash[file] =
          averageComplexity: averageComplexity(file)
          churn: churn(file)
          complexity: score(file)
          tokenCount: count(file)

        hash
      , {})

Export public API.

    exports.clog =
      churn: churn
      score: score
      report: report
      VERSION: "0.0.9"
