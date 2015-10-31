{clog} = require("./clog")

isCommand = (arg, commands) ->
  commands.reduce (memo, c) ->
    memo = true if arg[c]
    memo
  , false

USAGE = """
  Usage: clog [files] [options]

  Description:

    Static analysis tool for CoffeeScript code quality.

  Files:

    Space separated paths files or directories.
    Directories will be recursed to find
    .coffee, .coffee.md, and .litcoffee files to be analyzed

  Options:

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
