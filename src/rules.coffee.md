Rules for how each token type is weighted in terms of maintainability.

    rules =
      "+": 1
      "=": 1
      "BOOL": 1
      "IDENTIFIER": 1
      "->": 3
      "=>": 6
      "IF": 4
      "ELSE": 2
      "NUMBER": 1
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
      "FOR": 10
      "FORIN": 10
      "FOROF": 10
      "INDENT": 1
      "INDEX_START": 2
      "LEADING_WHEN": 1
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

    exports.rules = rules