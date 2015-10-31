rules = require "../rules"

# Metric: Token complexity

# Determines how complex code is by weighing each token based on maintainability.
# Using tokens is style agnostic and won't change based on
# comment / documentation style, or from personal whitespace style.
tokenComplexity = (tokens) ->
  tokens.reduce (sum, token) ->
    type = token[0]
    sum += (rules[type] || 0)
  , 0

module.exports = tokenComplexity
