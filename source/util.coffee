# Force number to be within min and max
clamp = (number, min, max) ->
  Math.max(Math.min(max, number), min)

# Divide, avoiding division by 0 error
divide = (numerator, denominator) ->
  if denominator
    numerator / denominator
  else
    0

# Sum the values of an object literal
objectValueTotal = (obj) ->
  Object.keys(obj).reduce (memo, key) ->
    memo += obj[key]
    memo
  , 0

# Find the max value of an object literal
objectValueMax = (obj) ->
  Object.keys(obj).reduce (memo, key) ->
    val = obj[key]
    memo = val if val > memo
    memo
  , 0

module.exports = {
  clamp
  divide
  objectValueMax
  objectValueTotal
}
