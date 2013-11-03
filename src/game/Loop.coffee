define ['../core', '../Events'], (hiv) ->
  console.info 'game/Loop loaded'

  {root} = hiv

  STATES =
    stopped: 0
    running: 1
    paused: 2

  _timeoutId = 0

  class hiv.game.Loop
    hiv.mixin this, hiv.Events

    constructor: (data) ->
      hiv.Events.call this, "loop"
      @reset()

    reset: () ->
      @_timeouts = {}
      @_t = 0
      this

    start: ->
      @_state = STATES.running
      @_animationFrame = root.requestAnimationFrame @onLoop
      this

    stop: ->
      @_state = STATES.stopped
      root.cancelAnimationFrame @onLoop
      @_animationFrame = null
      this

    onLoop: (t) =>
      dt = t - @_t
      @_t = t
      @trigger 'update', [t, dt]
      @runCallbacks(t, dt)
      @trigger 'render', [t, dt]
      @_animationFrame = root.requestAnimationFrame @onLoop

    timeout: (ms, callback) ->
      id = _timeoutId++
      timeouts = @_timeouts[id] =
        start: @_t + ms
        callback: callback
      clear: ->
        timeouts[id] = null

    isRunning: ->
      @_state is STATES.running

    runCallbacks: (t, dt) ->
      for id, data of @_timeouts
        if data and t >= data.start
          @_timeouts[id] = null
          data.callback(t, dt)
