# Clog

# A simple static analysis tool for CoffeeScript source code.
# Leverages CoffeeScript compiler, walking over all tokens
# in a file and weighing the code based on a number of heuristics
# corresponding to the token type.
{version} = require "../package.json"
{execSync} = require "child_process"

coffee = require "coffee-script"
# Register the compiler so we can can require .coffee files
require "coffee-script/register"
{tokens} = coffee

CoffeeLint = require "coffeelint"
CoffeeLint.registerRule require "coffeelint-no-long-functions"

complexityConfig =
  cyclomatic_complexity:
    value: 0
    level: "error"

functionLengthConfig =
  no_long_functions:
    value: 0
    level: "error"

rules = require "./rules"

fs = require "fs"
glob = require "glob"

nestedCoffeeScriptPattern = (path) ->
  path + "/**/*\.+(coffee|coffee\.md|litcoffee)"

# Force number to be within min and max
clamp = (number, min, max) ->
  Math.max(Math.min(max, number), min)

# Helper to return tokens for a given file path.
tokensForFile = (path) ->
  file = fs.readFileSync(path, "utf8")

  tokens file,
    literate: coffee.helpers.isLiterate(path)

## Metric: Function length

# Return the number of lines per function.
# Piggybacking off CoffeeLint implementation
# Report each function's length by setting CoffeeLint error threshold to 0
functionLength = (filePath) ->
  file = fs.readFileSync(filePath, "utf8")
  output = CoffeeLint.lint(file, functionLengthConfig).reduce (hash, description) ->
    if description.rule == "no_long_functions"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      hash[lineRange] = description.lineNumberEnd - description.lineNumber

    hash
  , {}

## Metric: Cyclomatic complexity

# A number representing how complex a file is
# Piggybacking off the implementation from CoffeeLint
# Report each function's complexity by setting CoffeeLint error threshold to 0
cyclomaticComplexity = (filePath) ->
  file = fs.readFileSync(filePath, "utf8")

  sum = 0
  output = CoffeeLint.lint(file, complexityConfig).reduce (hash, description) ->
    if description.rule == "cyclomatic_complexity"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      hash.lines[lineRange] = description.context
      sum += description.context

    hash
  , {lines: {}}

  output.total = sum
  output

## Metric: Churn

# Indicates how many times a file has been changed.
# The more it has been changed, the better a candidate it is for refactoring.

# Grep for commit since `git whatchanged` shows
# multiple lines of details from each commit.
churn = (filePath) ->
  command = "git whatchanged #{filePath} | grep 'commit' | wc -l"
  output = execSync command
  parseInt(output, 10)

## Metric: Token count

# The number of tokens in the file.
# Used in conjunction with token score to determine gpa.
count = (filePath) ->
  tokensForFile(filePath).length

## Metric: Token complexity

# Determines how complex code is by weighing each token based on maintainability.
# Using tokens is style agnostic and won't change based on
# comment / documentation style, or from personal whitespace style.
tokenComplexity = (filePath) ->
  tokensForFile(filePath).reduce (sum, token) ->
    type = token[0]
    sum += (rules[type] || 0)
  , 0

longFilePenalty = (tokens) ->
  if 0 <= tokens <= 200
    0
  else if 200 < tokens <= 300
    0.25
  else if 300 < tokens <= 500
    0.5
  else if tokens > 500
    1

## Metric: Complexity per token

# Gives the file a grade between 0-4
# based on token complexity compared to token length
gpa = (filePath) ->
  tokenCount = count(filePath)
  return 0 if tokenCount == 0

  base = tokenCount / tokenComplexity(filePath)
  penalized = (base * 4) - longFilePenalty(tokenCount)

  clamp(penalized, 0, 4)

letterGrade = (numericGrade) ->
  if 0 <= numericGrade <= 0.8
    "F"
  else if 0.8 < numericGrade <= 1.6
    "D"
  else if 1.6 < numericGrade <= 2.4
    "C"
  else if 2.4 < numericGrade <= 3.2
    "B"
  else if 3.2 < numericGrade <= 4
    "A"

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
analyze = (file) ->
  numericGrade = gpa(file)
  # TODO: consider caching file read here

  {
    gpa: numericGrade
    letterGrade: letterGrade(numericGrade)
    churn: churn(file)
    functionLength: functionLength(file)
    cyclomaticComplexity: cyclomaticComplexity(file)
    tokenComplexity: tokenComplexity(file)
    tokenCount: count(file)
  }

# Output scores per file
report = (filePaths, opts = {}) ->
  scores = files(filePaths).reduce (hash, file) ->
    hash[file] = analyze(file)
    hash
  , {}

  JSON.stringify(scores, null, opts.indentSpace)

# Public API
exports.clog =
  report: report
  VERSION: version
