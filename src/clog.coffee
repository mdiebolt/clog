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
# will only declare their classes
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

    output[exp.variable.base.value] = end - start

  output

classFunctions = (exp, parentNode) ->
  output = {}

  if exp.body?.classBody
    output = analyzeClass(parentNode)

  output

analyzeClass = (node) =>
  objectLiteralFunctions(node.expressions[0].body.expressions[0])

# recursively counting expressions
# will be much more reliable for
# determining method length than
# counting line numbers reported
# from locationData. This way we
# won't have to strip whitespace
# from each file
countExpressions = (node, count=1) ->
  node.expressions.forEach (exp) ->
    count += 1

    if exp.expression
      count += 1

    if body = (exp.value?.body || exp.body)
      count = countExpressions(body, count)

  count

nextNode = (exp, output) ->
  if body = exp.value?.body
    getMethods(body, output)

###
metric: method length

Name and length of each method.
Methods with bodies longer than
a specified value should be refactored
###
getMethods = (node, output={}) ->
  node.expressions.forEach (exp) ->
    merge(output, anonymousFunctions(exp))
    merge(output, variableFunctions(exp))
    merge(output, objectLiteralFunctions(exp))
    merge(output, classFunctions(exp, node))

    # pass the method output hash down so
    # the next node will have access to it
    nextNode(exp, output)

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
