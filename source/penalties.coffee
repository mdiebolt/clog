complexFile = (complexity) ->
  if 0 <= complexity <= 20
    1
  else if 20 < complexity <= 30
    0.9
  else if 30 < complexity <= 40
    0.8
  else if complexity > 40
    0.7

longFunction = (averageFunctionLength) ->
  if 0 <= averageFunctionLength <= 20
    1
  else if 20 < averageFunctionLength <= 40
    0.9
  else if 40 < averageFunctionLength <= 60
    0.8
  else if averageFunctionLength > 60
    0.7

longFile = (tokens) ->
  if 0 <= tokens <= 1000
    1
  else if 1000 < tokens <= 2000
    0.9
  else if 2000 < tokens <= 4000
    0.8
  else if tokens > 4000
    0.7

module.exports = {
  complexFile
  longFile
  longFunction
}
