{clamp, divide} = require "../util"
penalties = require "../penalties"

MIN_GPA = 0
MAX_GPA = 4

## Metric: GPA

# Gives the file a grade between 0-4
# based on token complexity compared to token length
gpa = (file, metrics) ->
  {tokenCount, tokenComplexity, functionLength, cyclomaticComplexity} = metrics
  base = divide(tokenCount, tokenComplexity) * MAX_GPA

  filePenalty = penalties.longFile(tokenCount)
  functionPenalty = penalties.longFunction(functionLength.average)
  complexityPenalty = penalties.complexFile(cyclomaticComplexity.total)

  penalized = base * filePenalty * functionPenalty * complexityPenalty

  clamp(penalized, MIN_GPA, MAX_GPA)

module.exports = gpa
