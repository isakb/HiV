define ['hiv'], (hiv) ->

  class Player
    hiv.mixin this, hiv.ui.Sprite

    constructor: (game, owner) ->
      @_lastStateId = null
      @game = game
      hiv.game.Entity.call this, hiv.extend({},
        shape: hiv.game.Entity.SHAPE.rectangle
        state: "right"
      , game.getAssets('player'))
      @_world = owner
      @_speed =
        x: 0
        y: 0

    update: (clock, delta) ->
      hiv.ui.Sprite::update.call this, clock, delta
      @_fall()  if @_isFalling
      pos = @_position
      # TODO: collision detection
      pos.x = @_position.x + @_speed.x * delta
      pos.y = @_position.y + @_speed.y * delta
      if @_position.y > 15000
        console.log "warping"
        @_position.y = -15000 + (@_position.y - 15000)
      else if @_position.y < -15000
        console.log "warping"
        @_position.y = 15000 - (@_position.y + 15000)

    _fall: ->
      @_speed.y = (@_speed.y + 0.015) * 0.99

    goLeft: ->
      return  if @_speed.x < -0.5
      @_speed.x -= 0.05
      @setState "left"  if @_speed.x < 0

    goRight: ->
      return  if @_speed.x > 0.5
      @_speed.x += 0.05
      @setState "right"  if @_speed.x > 0

    goUp: ->
      return  if @_isFalling
      @_isFalling = true
      @_speed.y = -0.4

    goDown: ->
      @_speed.y += 0.2

    shoot: ->
      direction = (if @_state is "left" then -1 else 1)
      position = @getPosition()
      console.log "SHOOTING"
      @_world.spawnBullet
        x: position.x
        y: position.y
      ,
        x: @_speed.x
        y: @_speed.y
      , @_state
