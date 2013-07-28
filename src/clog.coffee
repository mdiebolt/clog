{exec} = require 'child_process'
{nodes} = require 'coffee-script'

fs = require 'fs'
glob = require 'glob'

BLANK_LINES = /^\s*$[\n\r]{1,}/gm

merge = (object, properties) ->
  for key, val of properties
    object[key] = val

  object

# helper that reads a file sychronously
# and strips out newlines
readFile = (path) ->
  # get rid of newlines, in order to calculate method length more easily
  fs.readFileSync(path, 'utf8').replace(BLANK_LINES, '')

# assume that coffee script classes
# will only declare their methods
# in the object literal style. In
# this situation the class node will
# have an object key that you can
# analyze to determine method names
objectLiteralFunctions = (exp) ->
  methods = {}

  if (objects = exp.value?.base?.objects || exp.base?.objects)
    objects.forEach (obj, index) ->
      # make sure this isn't
      # just a property assignment
      if obj.value.params?
        methodName = obj.variable.base.value

        end = obj.locationData.last_line
        start = obj.locationData.first_line

        # special case last method in an object
        if index is objects.length - 1
          methodLength = end - start
        else
          methodLength = end - start - 1

        methods[methodName] = methodLength

  methods

anonymousFunctions = (exp) ->
  output = {}

  # anonymous methods
  if exp.params?
    start = exp.locationData.first_line
    end = exp.locationData.last_line

    output["anonymous"] ||= []
    output["anonymous"].push end - start

  output

variableFunctions = (exp) ->
  output = {}

  # functions assigned to variables
  if exp.value?.params?
    start = exp.value.locationData.first_line
    end = exp.value.locationData.last_line

    end_col = exp.value.locationData.last_column
    start_col = exp.value.locationData.first_column

    length = end - start

    # HACK: seems that nested functions report end columns
    # that are less than their start columns. Use this
    # fact to correct the off by one error that it causes
    length -= 1 if end_col < start_col

    output[exp.variable.base.value] = length

  output

classFunctions = (exp, parentNode) ->
  output = {}

  if exp.body?.classBody
    output = analyzeClass(parentNode)

  output

analyzeClass = (node) =>
  objectLiteralFunctions(node.expressions[0].body.expressions[0])

nextNode = (exp, output) ->
  if body = exp.value?.body
    getMethods(body, output)

###
metric: complexity score

A score that weights programming
constructs according to difficulty
to maintain. Files with a high
score should be refactored to
be more maintainable
###
scoreIfElse = (exp, nestedFactor=1, score=0) ->
  if exp.condition
    score += nestedFactor

  if exp.elseBody
    score += nestedFactor

  if (expressions = exp.body?.expressions || exp.elseBody?.expressions)
    expressions.forEach (exp) ->
      nestedFactor = nestedFactor * 2

      score = scoreIfElse(exp, nestedFactor, score)

  score

# TODO deal with nested cases
scoreSwitch = (exp, nestedFactor=1, score=0) ->
  if cases = exp.cases
    cases.forEach (c) ->
      score += 1

  if exp.otherwise
    score += 1

  score

calculateScore = (node, score=0) ->
  node.expressions.forEach (exp) ->
    score += scoreIfElse(exp)
    score += scoreSwitch(exp)

  score

score = (filePath) ->
  file = readFile(filePath)

  calculateScore(nodes(file))
#

###
metric: method length

Name and length of each method.
Methods with bodies longer than
a specified value should be refactored
###
getMethods = (node, output={}, nested=false) ->
  node.expressions.forEach (exp) ->
    merge(output, anonymousFunctions(exp))
    merge(output, variableFunctions(exp))
    merge(output, objectLiteralFunctions(exp))
    merge(output, classFunctions(exp, node))

    # pass the method output hash down so
    # the next node will have access to it
    nextNode(exp, output, nested)

  output

methods = (filePath) ->
  file = readFile(filePath)

  getMethods(nodes(file))
#

###
metric: churn

Indicates how many times a
file has been changed. The more
it has been changed, the better a
candidate it is for refactoring since
it probably does too many things
###
churn = (filePath, cb) ->
  # grep for commit since git whatchanged shows
  # multiple lines of details from each commit
  exec "git whatchanged #{filePath} | grep 'commit' | wc -l", cb
#

###
metric: count nodes

Simple proxy for complexity. The higher
the number of nodes a file has, the more
complex it is
###
accumulateNode = (node, totalNodes=0) ->
  node.expressions.forEach (n) ->
    totalNodes += 1

    if body = n.value?.body
      accumulateNode(body, totalNodes)

  totalNodes

countNodes = (filePath) ->
  file = readFile(filePath)

  accumulateNode(nodes(file))
#

# export public API
exports.clog =
  churn: churn
  countNodes: countNodes
  methods: methods
  score: score
