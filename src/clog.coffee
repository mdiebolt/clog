{exec} = require 'child_process'
{nodes, tokens} = require 'coffee-script'

fs = require 'fs'

SCORE_MAP =
  "+": 1
  "=": 1
  "BOOL": 1
  "IDENTIFIER": 1
  "->": 3
  "=>": 6
  "IF": 4
  "ELSE": 2
  "NUMBER": 1 # TODO this is worth more points if not 0 or 1
  "(": 1
  ",": 1
  "-": 1
  ".": 2
  ":": 1
  "?": 3
  "?.": 5
  "@": 5
  "CALL_START": 2
  "CLASS": 30
  "COMPARE": 1
  "EXTENDS": 15
  "FOR": 10 # Not sure what code this corresponds with
  "FORIN": 10
  "FOROF": 10
  "INDENT": 1
  "INDEX_START": 2
  "LEADING_WHEN": 1 # Check if this is from switch
  "LOGIC": 1
  "MATH": 1
  "NULL": 3
  "PARAM_START": 3
  "REGEX": 10
  "RETURN": 0
  "STRING": 1
  "SUPER": 7
  "SWITCH": 7
  "TERMINATOR": 1
  "UNARY": 2
  "[": 2
  "{": 2

readFile = (path) ->
  fs.readFileSync(path, 'utf8')

score = (filePath) ->
  file = readFile(filePath)

  tokens(file).reduce (sum, token) ->
    type = token[0]

    sum + (SCORE_MAP[type] || 0)
  , 0

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

# export public API
exports.clog =
  churn: churn
  score: score
