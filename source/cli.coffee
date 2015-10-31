{clog} = require("./clog")

isCommand = (arg, commands) ->
  commands.reduce (memo, c) ->
    if arg[c]
      memo = true

    memo
  , false

USAGE = """
  Usage: clog path/to/file1.coffee path/to/directory

  -h, --help    display this message
  -v, --version display the current version
"""

run = (argv) ->
  message = USAGE

  if isCommand(argv, ["h", "help"])
    message = USAGE
  else if isCommand(argv, ["v", "version"])
    message = clog.VERSION
  else if argv._.length
    if isCommand(argv, ["p", "pretty-print"])
      printOptions = { indentSpace: 2 }
    else
      printOptions = {}

    message = clog.report(argv._, printOptions)

  message

module.exports = run
