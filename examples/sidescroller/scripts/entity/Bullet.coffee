define ['hiv'], (hiv) ->

  class Bullet
    hiv.mixin this, hiv.ui.Sprite

    constructor: (settings, game) ->
      @_lastStateId = null
      @game = game
      hiv.ui.Sprite.call this, hiv.extend({},
        shape: hiv.game.Entity.SHAPE.circle
        state: settings.direction
      , game.getAssets('entities').bullet, settings)
      @_speed = settings.speed
      @_fly()

    update: (clock, delta) ->
      hiv.ui.Sprite::update.call this, clock, delta
      @_fly()
      @_position.x += @_speed.x * delta
      @_position.y += @_speed.y * delta

    _fly: ->
      @_speed.x *= 50 / (50 + @_speed.x * @_speed.x)
      @_speed.y = (@_speed.y + 0.02) * 0.99
