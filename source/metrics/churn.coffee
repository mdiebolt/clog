{execSync} = require "child_process"

## Metric: Churn

# Indicates how many times a file has been changed.
# The more it has been changed, the better a candidate it is for refactoring.

# Grep for commit since `git whatchanged` shows
# multiple lines of details from each commit.
churn = (filePath) ->
  command = "git whatchanged #{filePath} | grep 'commit' | wc -l"
  output = execSync command
  parseInt(output, 10)

module.exports = churn
