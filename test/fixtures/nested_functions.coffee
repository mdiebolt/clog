aFn = (arg) ->
  arg + 1

  nestedFn = ->
    one()
    two()

    superNestedFn = =>
      a()
      b()
      c()
      d()

    three()

  return arg
