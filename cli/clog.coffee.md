Require clog.

    {clog} = require("../lib/clog")

Require minimist for easy argument processing.

    argv = require("minimist")(process.argv.slice(2))

Helper for processing commands.

    command = (commands...) ->
      commands.reduce (memo, c) ->
        memo = true if argv[c]
        memo
      , false

Default usage explanation.

    USAGE = """

      Usage: clog path/to/file1.coffee path/to/file2.coffee

      -h, --help    display this message
      -v, --version display the current version
    """

Execute appropriate command based on flags / arguments passed.

    if command("h", "help")
      message = USAGE
    else if command("v", "version")
      message = clog.VERSION
    else if argv._.length
      message = clog.report(argv._)
    else
      message = USAGE

    console.log message
