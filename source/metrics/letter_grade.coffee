# Metric: Letter grade

# Translate score into letter grade on A-F scale
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

module.exports = letterGrade
