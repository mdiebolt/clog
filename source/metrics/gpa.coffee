{clamp} = require "../util"
penalties = require "../penalties"

MIN_GPA = 0
MAX_GPA = 4

## Metric: GPA

# Gives the file a grade between 0-4
# based on token complexity compared to token length
gpa = (file, metrics) ->
  {tokenCount, tokenComplexity} = metrics
  return 0 unless tokenCount

  raw = tokenCount / tokenComplexity
  base = raw * MAX_GPA

  filePenalty = penalties.longFile(tokenCount)
  functionPenalty = penalties.longFunction(metrics.functionLength.average)
  complexityPenalty = penalties.complexFile(metrics.cyclomaticComplexity.total)

  penalized = base * filePenalty * functionPenalty * complexityPenalty

  clamp(penalized, MIN_GPA, MAX_GPA)

module.exports = gpa
