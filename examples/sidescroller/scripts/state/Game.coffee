define [
  'hiv'
  '../entity/Player'
  '../entity/Bullet'
], (hiv, Player, Bullet) ->

  gameEntity = {
    Player
    Bullet
  }

  class Game
    hiv.mixin this, hiv.game.State

    onKey:
      left:   '_onKeyLeft'
      right:  '_onKeyRight'
      up:     '_onKeyUp'
      down:   '_onKeyDown'
      space:  '_onKeySpace'

    constructor: (game) ->
      hiv.game.State.call this, game, 'menu'
      @_clock = 0
      @_layers = []
      @_guiEntities = {}
      @_player = null
      @_playerStart = null
      @_bullets = []
      @_enemies = []
      @_exit = null
      @_locked = false

    reset: ->
      @_level = '01'

    enter: ->
      console.group 'Game state'
      @reset()
      hiv.game.State::enter.call this
      @_locked = true
      @_enterLevel @_level
      input = @game.getInput()
      for key, methodName of @onKey
        input.bind key, @[methodName], this

    leave: ->
      console.groupEnd()
      input = @game.getInput()
      for key, methodName of @onKey
        input.unbind key, @[methodName]
      hiv.game.State::leave.call this

    update: (clock, delta) ->
      @_player.update clock, delta
      for e in @_guiEntities
        continue  unless e?
        e.update clock, delta
      for bullet in @_bullets
        continue  unless bullet?
        bullet.update clock, delta
      @_clock = clock

    render: (clock, delta) ->
      renderer = @game.getRenderer()
      renderer.clear()
      renderer.moveCameraTo @_player
      for layer in @_layers
        if layer is 'entities'
          for bullet of @_bullets
            renderer.renderEntityBox @_bullets[bullet], '#bad'
          renderer.renderEntityBox @_player, '#f4f'
          #renderer.renderEntityBox @_playerStart, '#0f0'
        else
          renderer.renderLayer(
            layer,
            @game.getAssets('tilesets'),
            @_tileWidth,
            @_tileHeight
          )

      # Only for debugging
      renderer.renderLayer(
        @_collisionLayer,
        @game.getAssets('tilesets'),
        @_tileWidth,
        @_tileHeight
      )

      for e of @_guiEntities
        entity = @_guiEntities[e]
        if entity is null
          continue
        else if entity.type
          renderer['render' + entity.type] entity
        else
          renderer.renderUIEntity @_guiEntities[e]
      renderer.flush()

    _enterLevel: (level) ->
      levelConfig = @game.getAssets('levels')[level]
      assets = @game.assets
      width = @game.settings.width
      height = @game.settings.height
      @_player = new Player(@game, this)
      @_tileWidth = levelConfig.tilewidth
      @_tileHeight = levelConfig.tileheight
      tileSets = levelConfig.tilesets
      layers = levelConfig.layers
      @_tileCache = {}
      for layer in layers
        @_makeLayer layer
      @_locked = false
      @_guiEntities.title = new hiv.ui.Text
        text: levelConfig.properties.title
        font: @game.fonts.headline
        position:
          x: width / 2
          y: -200
        color: 'yellow'
      @_guiEntities.description = new hiv.ui.Text
        text: levelConfig.properties.description
        font: @game.fonts.small
        position:
          x: width / 2
          y: height + 24
      @_guiEntities.title.setTween 1000,
        y: height / 2 - 100
      , hiv.game.Entity.TWEEN.easeOut
      @_loop = @game.getLoop()
      @_loop.timeout 2000, =>
        @_guiEntities.description.setTween 500,
          y: height / 2 + 100
        , hiv.game.Entity.TWEEN.easeOut
      @_loop.timeout 5000, =>
        @_guiEntities.title.setTween 500,
          x: -1000
        , hiv.game.Entity.TWEEN.easeIn
        @_guiEntities.description.setTween 500,
          x: -1000
        , hiv.game.Entity.TWEEN.easeIn

    _makeLayer: (layer) ->
      switch layer.type
        when 'tilelayer'
          if layer.name is 'collision'
            @_collisionLayer = layer
          else
            @_layers.push layer
        when 'objectgroup'
          if layer.name is 'entities'
            @_addEntities layer.objects
            # Placeholder for rendering order:
            @_layers.push 'entities'
        else
          console.info 'Ignoring layer: ' + layer.name

    _addEntities: (entities) ->
      for entity in entities
        if entity.type is 'Player'
          @_player.setPosition
            x: entity.x
            y: entity.y
          @_player.width = entity.width
          @_player.height = entity.height
          @_playerStart = new hiv.game.Entity(
            position:
              x: entity.x
              y: entity.y
            width: entity.width
            height: entity.height
          )
        else
          console.warn 'Ignored map entity: ' + entity.type

    spawnBullet: (position, speed, direction) ->
      @_bullets.push new Bullet(
        direction: direction
        position: position
        speed:
          x: speed.x + 0.5 * ((if direction is 'right' then 1 else -1))
          y: speed.y - 0.3
      , @game)

    _onKeyLeft:    -> @_player.goLeft()
    _onKeyRight:   -> @_player.goRight()
    _onKeyUp:      -> @_player.goUp()
    _onKeyDown:    -> @_player.goDown()
    _onKeySpace:   -> @_player.shoot()
