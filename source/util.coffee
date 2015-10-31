# Force number to be within min and max
clamp = (number, min, max) ->
  Math.max(Math.min(max, number), min)

# Divide, avoiding division by 0 error
divide = (numerator, denominator) ->
  if denominator
    numerator / denominator
  else
    0

module.exports = {
  clamp
  divide
}
