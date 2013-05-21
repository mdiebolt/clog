{spawn, exec} = require 'child_process'
{nodes} = require 'coffee-script'

fs = require 'fs'
glob = require 'glob'

BLANK_LINES = /^\s*$[\n\r]{1,}/gm

anonymousId = 0

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
    if exp.value?.base?.properties
      exp.value?.base?.properties.forEach (property, index) ->
        base = exp.value.base

        currentObject = base.objects[index]

        if property.value?.params?
          start = property.locationData.first_line
          end = property.locationData.last_line

          output[currentObject.variable.base.value] = end - start

  output

methods = (filePath) ->
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
