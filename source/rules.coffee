# Rules for how each token type is weighted in terms of maintainability.
module.exports =
  "+": 1
  "=": 1
  "(": 1
  ",": 1
  "-": 1
  ":": 1

  "BOOL": 1
  "COMPARE": 1
  "IDENTIFIER": 1
  "INDENT": 1
  "LEADING_WHEN": 1
  "LOGIC": 1
  "MATH": 1
  "NUMBER": 1
  "STRING": 1
  "TERMINATOR": 1
  "UNARY_MATH": 1
  "CALL_START": 1
  "CALL_END": 1

  ".": 2
  "[": 2
  "{": 2

  "COMPOUND_ASSIGN": 2
  "INDEX_START": 2
  "PARAM_START": 2

  "->": 2.5
  "?": 2.5

  "RELATION": 2.5
  "SHIFT": 2.5
  "UNARY": 2.5

  "++": 2.75

  "--": 3
  "=>": 3

  "ELSE": 3
  "IF": 3
  "NULL": 3
  "REGEX": 3
  "SWITCH": 3

  "@": 3.25
  "?.": 3.25

  "FOR": 3.5
  "FORIN": 3.5
  "FOROF": 3.5
  "SUPER": 3.5

  "EXTENDS": 3.75

  "CLASS": 4
