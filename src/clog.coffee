{spawn, exec} = require 'child_process'

exports.clog =
  churn: (filePath) ->
    exec "git whatchanged | wc -l"

