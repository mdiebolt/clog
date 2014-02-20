# Clog

A simple static analysis tool for CoffeeScript source code.
Leverages CoffeeScript compiler, walking over all tokens
in a file and weighing the code based on a number of heuristics
corresponding to the token type.

    execSync = require "execSync"
    {tokens} = require "coffee-script"
    {rules} = require "../lib/rules"

    fs = require "fs"
    glob = require "glob"

Helper to read a file in utf-8.

    read = (path) ->
      fs.readFileSync(path, "utf8")

## Metric: Churn

Indicates how many times a file has been changed. The more
it has been changed, the better a candidate it is for refactoring.

    churn = (filePath) ->

Grep for commit since git whatchanged shows
multiple lines of details from each commit.

      command = "git whatchanged #{filePath} | grep 'commit' | wc -l"
      output = execSync.exec command
      parseInt(output.stdout, 10)

## Metric: Token score

Determines how complex code is by weighing each token
based on maintainability. Using tokens is style agnostic
and won't change based on comment / documentation style,
or from personal whitespace style.

    score = (filePath) ->
      literate = /\.litcoffee|\.coffee\.md/.test(filePath)
      file = read(filePath)

      tokens(file, literate: literate).reduce (sum, token) ->
        type = token[0]
        sum + (rules[type] || 0)
      , 0

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
          pattern = "#{path}/**/*.+(coffee|coffee\.md|\.litcoffee)"
          list = list.concat(glob.sync pattern)

        list
      , []

Output scores per file.

    report = (filePaths) ->
      files(filePaths).reduce (hash, file) ->
        hash[file] =
          churn: churn(file)
          complexity: score(file)

        hash
      , {}

Export public API.

    exports.clog =
      churn: churn
      score: score
      report: report
      VERSION: "0.0.8"
