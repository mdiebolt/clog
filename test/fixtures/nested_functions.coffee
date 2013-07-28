aFn = (arg) ->
  arg + 1

  nestedFn = ->
    one()
    two()

    superNestedFn = =>
      a()
      b()
      c()

      if true
        d()

    three()

  return arg
