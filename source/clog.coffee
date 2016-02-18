{version} = require "../package.json"

# Metrics
churn = require "./metrics/churn"
tokenComplexity = require "./metrics/token_complexity"
cyclomaticComplexity = require "./metrics/cyclomatic_complexity"
functionLength = require "./metrics/function_length"
letterGrade = require "./metrics/letter_grade"
gpa = require "./metrics/gpa"

coffee = require "coffee-script"
{tokens, compile} = coffee

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
      matchingFiles = glob.sync nestedCoffeeScriptPattern(path)
      list = list.concat(matchingFiles)

    list
  , []

# Metric summary for an individual file
analyze = (filePath) ->
  file = fs.readFileSync(filePath, "utf8")

  summary = {}

  try
    # make sure the file is valid CoffeeScript before running analysis
    compile file
    summary = validFileSummary(filePath, file)
  catch e
    summary.error = "#{e.name}: #{e.stack.split("\n")[0]}"

  summary

validFileSummary = (filePath, file) ->
  fileTokens = tokens file,
    literate: coffee.helpers.isLiterate(filePath)

  summary =
    churn: churn(filePath)
    functionLength: functionLength(file)
    cyclomaticComplexity: cyclomaticComplexity(file)
    tokenComplexity: tokenComplexity(fileTokens)
    tokenCount: fileTokens.length

  # calculate GPA based on other metrics
  summary.gpa = gpa(file, summary)
  summary.letterGrade = letterGrade(summary.gpa)

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
# in a file and weighing the code based on a heuristic
# corresponding to the token type.
exports.clog =
  report: report
  analyze: analyze
  VERSION: version
