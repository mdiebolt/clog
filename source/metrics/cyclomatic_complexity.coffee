CoffeeLint = require "coffeelint"
{divide} = require "../util"

complexityConfig =
  cyclomatic_complexity:
    value: 0
    level: "error"

# Metric: Cyclomatic complexity

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

module.exports = cyclomaticComplexity
