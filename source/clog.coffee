{version} = require "../package.json"

# Metrics
churn = require "./metrics/churn"
tokenComplexity = require "./metrics/token_complexity"
cyclomaticComplexity = require "./metrics/cyclomatic_complexity"
functionLength = require "./metrics/function_length"
letterGrade = require "./metrics/letter_grade"
gpa = require "./metrics/gpa"

coffee = require "coffee-script"
{tokens} = coffee

fs = require "fs"
glob = require "glob"

nestedCoffeeScriptPattern = (path) ->
  path + "/**/*\.+(coffee|coffee\.md|litcoffee)"

# Return an array of CoffeeScript files
# based on file filePaths or directories passed in
files = (paths) ->
  paths.reduce (list, path) ->
    stats = fs.lstatSync(path)

    if stats.isFile()
      list.push path
    else if stats.isDirectory()
      pattern = nestedCoffeeScriptPattern(path)
      list = list.concat(glob.sync pattern)

    list
  , []

# Metrics for an individual file
analyze = (filePath) ->
  file = fs.readFileSync(filePath, "utf8")

  fileTokens = tokens file,
    literate: coffee.helpers.isLiterate(filePath)

  summary = {
    churn: churn(filePath)
    functionLength: functionLength(file)
    cyclomaticComplexity: cyclomaticComplexity(file)
    tokenComplexity: tokenComplexity(fileTokens)
    tokenCount: fileTokens.length
  }

  numericGrade = gpa(file, summary)

  summary.gpa = numericGrade
  summary.letterGrade = letterGrade(numericGrade)

  summary

# Output scores per file
report = (filePaths, opts = {}) ->
  scores = files(filePaths).reduce (hash, file) ->
    hash[file] = analyze(file)
    hash
  , {}

  JSON.stringify(scores, null, opts.indentSpace)

# Clog

# A simple static analysis tool for CoffeeScript source code.
# Leverages CoffeeScript compiler, walking over all tokens
# in a file and weighing the code based on a number of heuristics
# corresponding to the token type.
exports.clog =
  report: report
  VERSION: version
