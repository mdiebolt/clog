{spawn, exec} = require 'child_process'
{nodes} = require 'coffee-script'

fs = require 'fs'
glob = require 'glob'

BLANK_LINES = /^\s*$[\n\r]{1,}/gm

anonymousId = 0

# assume that coffee script classes
# will only declare their classes
# in the object literal style. In
# this situation the class node will
# have an object key that you can
# analyze to determine method names
objectLiteralMethods = (objectsArray) ->
  methods = {}

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

getNode = (node, totalNodes=0) ->
  node.expressions.forEach (n) ->
    if (body = n.value?.body)?
      getNode(body, totalNodes)

    totalNodes += 1

  return totalNodes

eachExpression = (node, cb) ->
  node.expressions.forEach cb

eachProperty = (node, cb) ->
  node.properties.forEach cb

getMethods = (node, output={}) ->
  # if the first expression defines a class
  # TODO make this more robust to be able to
  # handle classes defined anywhere
  if node.expressions[0]?.body?.classBody
    analyzeClass(node)
  else
    # functions assigned to variables
    eachExpression node, (exp) ->
      # anon methods
      if exp.params?
        start = exp.locationData.first_line
        end = exp.locationData.last_line

        anonymousId += 1

        output["anonymous#{anonymousId}"] = end - start

      if exp.value?.params?
        start = exp.value.locationData.first_line
        end = exp.value.locationData.last_line

        output[exp.variable.base.value] = end - start

      if (body = exp.value?.body)?
        getMethods(body, output)

      # find object literal methods
      if (objects = exp.value?.base?.objects)
        methods = objectLiteralMethods(objects)

        for name, length of methods
          output[name] = length

    output

methods = (filePath) ->
  # get rid of newlines, in order to calculate method length more easily
  file = fs.readFileSync(filePath, 'utf8').replace(BLANK_LINES, '')

  tree = nodes(file)

  getMethods(tree)

churn = (filePath, cb) ->
  # grep for commit since git whatchanged shows
  # multiple lines of details from each commit
  exec "git whatchanged #{filePath} | grep 'commit' | wc -l", cb

countNodes = (filePath) ->
  tree = nodes(fs.readFileSync(filePath, 'utf8'))

  getNode(tree)

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
