tokenComplexity = require "./token_complexity"
{clamp} = require "../util"

MIN_GPA = 0
MAX_GPA = 4

## Metric: GPA

# Gives the file a grade between 0-4
# based on token complexity compared to token length
rawGpa = (file, tokens) ->
  tokenCount = tokens.length
  return 0 unless tokenCount

  raw = tokenCount / tokenComplexity(tokens)
  base = raw * MAX_GPA

gpa = (base, scorePenalties) ->
  penalized = base * scorePenalties.filePenalty * scorePenalties.functionPenalty * scorePenalties.complexityPenalty
  clamp(penalized, MIN_GPA, MAX_GPA)

module.exports = {
  rawGpa
  gpa
}
