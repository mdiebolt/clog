# Clog

# A simple static analysis tool for CoffeeScript source code.
# Leverages CoffeeScript compiler, walking over all tokens
# in a file and weighing the code based on a number of heuristics
# corresponding to the token type.
{version} = require "../package.json"
{execSync} = require "child_process"
{tokens} = require "coffee-script"
rules = require "./rules"

fs = require "fs"
glob = require "glob"

NESTED_COFFEESCRIPT_PATTERN = "/**/*\.+(coffee|coffee\.md|litcoffee)"

# Force number to be within min and max
clamp = (number, min, max) ->
  Math.max(Math.min(max, number), min)

# Helper to determine if filePath represents a literate Coffee file.
# TODO: use CoffeeScript built in helper for this
isLiterate = (path) ->
  /\.litcoffee|\.coffee\.md/i.test(path)

# Helper to return tokens for a given file path.
tokensForFile = (path) ->
  file = fs.readFileSync(path, "utf8")

  tokens file,
    literate: isLiterate(path)

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
complexity = (filePath) ->
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

  base = tokenCount / complexity(filePath)
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
      pattern = path + NESTED_COFFEESCRIPT_PATTERN
      list = list.concat(glob.sync pattern)

    list
  , []

# Metrics for an individual file
analyze = (file) ->
  numericGrade = gpa(file)

  {
    gpa: numericGrade
    letterGrade: letterGrade(numericGrade)
    churn: churn(file)
    complexity: complexity(file)
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
