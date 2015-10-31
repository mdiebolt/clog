CoffeeLint = require "coffeelint"
CoffeeLint.registerRule require "coffeelint-no-long-functions"

{divide, objectValueMax, objectValueTotal} = require "../util"

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
  output = CoffeeLint.lint(file, functionLengthConfig).reduce (hash, description) ->
    if description.rule == "no_long_functions"
      lineRange = description.lineNumber + "-" + description.lineNumberEnd
      hash.lines[lineRange] = description.lineNumberEnd - description.lineNumber

    hash
  , {lines: {}}

  output.total = objectValueTotal(output.lines)
  output.average = divide(output.total, Object.keys(output.lines).length)
  output.max = objectValueMax(output.lines)

  output

module.exports = functionLength
