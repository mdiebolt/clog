class Car
  initialize: ->
    @started = false
    @speed = 0

  honk: ->
    alert('beep!')

  drive: =>
    @started = true

    @accelerate(5, 50)

  accelerate: (increase, toSpeed) =>
    @speed += increase

    if @speed < toSpeed
      @accelerate(increase, toSpeed)
