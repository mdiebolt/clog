{spawn, exec} = require 'child_process'
{nodes} = require 'coffee-script'

fs = require 'fs'
glob = require 'glob'

getNode = (node, totalNodes=0) ->
  node.expressions.forEach (n) ->
    if (body = n.value?.body)?
      getNode(body, totalNodes)

    totalNodes += 1

  return totalNodes

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

  # Go through all CoffeeScript files and apply
  # each static analysis method.
  # TODO: build up a JSON report of code score
  run: ->
    glob '**/*.coffee', (err, files) ->
      files.forEach (file) ->
        churn file, (err, output) ->
          console.log output
