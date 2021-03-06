// Generated by CoffeeScript 1.10.0
(function() {
  var USAGE, clog, isCommand, run;

  clog = require("./clog").clog;

  isCommand = function(arg, commands) {
    return commands.reduce(function(memo, c) {
      if (arg[c]) {
        memo = true;
      }
      return memo;
    }, false);
  };

  USAGE = "Usage: clog [files] [options]\n\nDescription:\n\n  Static analysis tool for CoffeeScript code quality.\n\nFiles:\n\n  Space separated paths files or directories.\n  Directories will be recursed to find\n  .coffee, .coffee.md, and .litcoffee files to be analyzed\n\nOptions:\n\n  -h, --help    display this message\n  -v, --version display the current version";

  run = function(argv) {
    var message, printOptions;
    message = USAGE;
    if (isCommand(argv, ["h", "help"])) {
      message = USAGE;
    } else if (isCommand(argv, ["v", "version"])) {
      message = clog.VERSION;
    } else if (argv._.length) {
      if (isCommand(argv, ["p", "pretty-print"])) {
        printOptions = {
          indentSpace: 2
        };
      } else {
        printOptions = {};
      }
      message = clog.report(argv._, printOptions);
    }
    return message;
  };

  module.exports = run;

}).call(this);
