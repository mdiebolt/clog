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

MIN_GPA = 0
MAX_GPA = 4

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

# Safely divide to figure out average
divide = (numerator, denominator) ->
  if denominator
    numerator / denominator
  else
    0

## Metric: Function length

# Return the number of lines per function.
# Piggybacking off CoffeeLint implementation
# Report each function's length by setting CoffeeLint error threshold to 0
# TODO: fix this. Right now CoffeeLint's function length plugin incorrectly
# counts comments preceeding a method as part of the same indentation level
# method above it.
functionLength = (file) ->
  sum = max = 0
  output = CoffeeLint.lint(file, functionLengthConfig).reduce (hash, description) ->
    if description.rule == "no_long_functions"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      length = description.lineNumberEnd - description.lineNumber
      hash.lines[lineRange] = length
      sum += length
      if length > max
        max = length

    hash
  , {lines: {}}

  output.average = divide(sum, Object.keys(output.lines).length)
  output.max = max

  output

## Metric: Cyclomatic complexity

# A number representing how complex a file is
# Piggybacking off the implementation from CoffeeLint
# Report each function's complexity by setting CoffeeLint error threshold to 0
cyclomaticComplexity = (file) ->
  sum = max = 0
  output = CoffeeLint.lint(file, complexityConfig).reduce (hash, description) ->
    if description.rule == "cyclomatic_complexity"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      hash.lines[lineRange] = description.context
      sum += description.context
      if description.context > max
        max = description.context

    hash
  , {lines: {}}

  output.average = divide(sum, Object.keys(output.lines).length)
  output.max = max
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

## Metric: Token complexity

# Determines how complex code is by weighing each token based on maintainability.
# Using tokens is style agnostic and won't change based on
# comment / documentation style, or from personal whitespace style.
tokenComplexity = (tokens) ->
  tokens.reduce (sum, token) ->
    type = token[0]
    sum += (rules[type] || 0)
  , 0

complexFilePenalty = (complexity) ->
  if 0 <= complexity <= 20
    1
  else if 20 < complexity <= 30
    0.9
  else if 30 < complexity <= 40
    0.8
  else if complexity > 40
    0.7

longFunctionPenalty = (averageFunctionLength) ->
  if 0 <= averageFunctionLength <= 20
    1
  else if 20 < averageFunctionLength <= 40
    0.9
  else if 40 < averageFunctionLength <= 60
    0.8
  else if averageFunctionLength > 60
    0.7

longFilePenalty = (tokens) ->
  if 0 <= tokens <= 1000
    1
  else if 1000 < tokens <= 2000
    0.9
  else if 2000 < tokens <= 4000
    0.8
  else if tokens > 4000
    0.7

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

## Metric: Complexity per token

# Gives the file a grade between 0-4
# based on token complexity compared to token length
rawGpa = (file, tokens) ->
  tokenCount = tokens.length
  return 0 unless tokenCount

  raw = tokenCount / tokenComplexity(tokens)
  raw * MAX_GPA

gpa = (base, penalties) ->
  penalized = base * penalties.filePenalty * penalties.functionPenalty * penalties.complexityPenalty
  clamp(penalized, MIN_GPA, MAX_GPA)

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

  fLength = functionLength(file)
  cComplexity = cyclomaticComplexity(file)

  raw = rawGpa(file, fileTokens)
  numericGrade = gpa raw,
    filePenalty: longFilePenalty(fileTokens.length)
    functionPenalty: longFunctionPenalty(fLength.average)
    complexityPenalty: complexFilePenalty(cComplexity.total)

  {
    gpa: numericGrade
    letterGrade: letterGrade(numericGrade)
    churn: churn(filePath)
    functionLength: fLength
    cyclomaticComplexity: cComplexity
    tokenComplexity: tokenComplexity(fileTokens)
    tokenCount: fileTokens.length
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
