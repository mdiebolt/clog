CoffeeLint = require "coffeelint"
CoffeeLint.registerRule require "coffeelint-no-long-functions"

{divide} = require "../util"

functionLengthConfig =
  no_long_functions:
    value: 0
    level: "error"

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
      max = length if length > max

    hash
  , {lines: {}}

  output.average = divide(sum, Object.keys(output.lines).length)
  output.max = max

  output

module.exports = functionLength
