# Clog

# A simple static analysis tool for CoffeeScript source code.
# Leverages CoffeeScript compiler, walking over all tokens
# in a file and weighing the code based on a number of heuristics
# corresponding to the token type.
{version} = require "../package.json"
{execSync} = require "child_process"

# Metrics
churn = require "./metrics/churn"
tokenComplexity = require "./metrics/token_complexity"
cyclomaticComplexity = require "./metrics/cyclomatic_complexity"
functionLength = require "./metrics/function_length"
letterGrade = require "./metrics/letter_grade"
{gpa, rawGpa} = require "./metrics/gpa"

# Penalties
penalties = require "./penalties"

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

  fLength = functionLength(file)
  cComplexity = cyclomaticComplexity(file)

  raw = rawGpa(file, fileTokens)
  numericGrade = gpa raw,
    filePenalty: penalties.longFile(fileTokens.length)
    functionPenalty: penalties.longFunction(fLength.average)
    complexityPenalty: penalties.complexFile(cComplexity.total)

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
