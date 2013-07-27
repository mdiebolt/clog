{spawn, exec} = require 'child_process'
{nodes} = require 'coffee-script'

fs = require 'fs'
glob = require 'glob'

BLANK_LINES = /^\s*$[\n\r]{1,}/gm

merge = (object, properties) ->
  for key, val of properties
    object[key] = val

  object

# assume that coffee script classes
# will only declare their classes
# in the object literal style. In
# this situation the class node will
# have an object key that you can
# analyze to determine method names
objectLiteralMethods = (objectsArray) ->
  methods = {}

  # TODO skip keys whose values aren't functions
  objectsArray.forEach (obj, index) ->
    methodName = obj.variable.base.value

    # special case last method in an object
    if index is objectsArray.length - 1
      methodLength = (obj.locationData.last_line - obj.locationData.first_line)
    else
      methodLength = (obj.locationData.last_line - obj.locationData.first_line) - 1

    methods[methodName] = methodLength

  methods

analyzeClass = (node) =>
  objects = node.expressions[0].body.expressions[0].base.objects

  objectLiteralMethods(objects)

eachExpression = (node, cb) ->
  node.expressions.forEach cb

eachProperty = (node, cb) ->
  node.properties.forEach cb

getMethods = (node, output={}) ->
  # functions assigned to variables
  eachExpression node, (exp) ->
    # anonymous methods
    if exp.params?
      start = exp.locationData.first_line
      end = exp.locationData.last_line

      output["anonymous"] ||= []
      output["anonymous"].push end - start

    # if this expression has params
    # then it's a function. Analyze
    # the method body length
    if exp.value?.params?
      start = exp.value.locationData.first_line
      end = exp.value.locationData.last_line

      output[exp.variable.base.value] = end - start

    # find object literal methods
    if (objects = exp.value?.base?.objects)
      methods = objectLiteralMethods(objects)

      # merge the object literal
      # properties with our output hash
      merge(output, methods)

    # find coffee script class methods
    if exp.body?.classBody
      methods = analyzeClass(node)

      merge(output, methods)

    # get nested nodes
    if (body = exp.value?.body)?
      getMethods(body, output)

  output

readFile = (path) ->
  # get rid of newlines, in order to calculate method length more easily
  fs.readFileSync(path, 'utf8').replace(BLANK_LINES, '')

methods = (filePath) ->
  file = readFile(filePath)

  getMethods(nodes(file))

###
metric: churn

a metric that indicates how many times a
particular file has been changed. The more
it has been changed, the better it's a
candidate for refactoring since it probably
does too many things
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
getNode = (node, totalNodes=0) ->
  node.expressions.forEach (n) ->
    totalNodes += 1

    if (body = n.value?.body)?
      getNode(body, totalNodes)

  totalNodes

countNodes = (filePath) ->
  file = readFile(filePath)

  getNode(nodes(file))
#

# export public API
exports.clog =
  churn: churn
  countNodes: countNodes
  methods: methods

  # Go through all CoffeeScript files and apply
  # each static analysis method.
  # TODO: build up a JSON report of code score
  run: ->
    glob '**/*.coffee', (err, files) ->
      files.forEach (file) ->
        churn file, (err, output) ->
          console.log output
