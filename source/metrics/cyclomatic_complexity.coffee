CoffeeLint = require "coffeelint"
{divide, objectValueMax, objectValueTotal} = require "../util"

complexityConfig =
  cyclomatic_complexity:
    value: 0
    level: "error"

# Metric: Cyclomatic complexity

# A number representing how complex a file is
# Piggybacking off the implementation from CoffeeLint
# Report each function's complexity by setting CoffeeLint error threshold to 0
cyclomaticComplexity = (file) ->
  output = CoffeeLint.lint(file, complexityConfig).reduce (hash, description) ->
    if description.rule == "cyclomatic_complexity"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      hash.lines[lineRange] = description.context

    hash
  , {lines: {}}

  output.total = objectValueTotal(output.lines)
  output.average = divide(output.total, Object.keys(output.lines).length)
  output.max = objectValueMax(output.lines)

  output

module.exports = cyclomaticComplexity
