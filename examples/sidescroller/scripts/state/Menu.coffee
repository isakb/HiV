define [
  'hiv'
  '../Scene'
], (hiv, Scene) ->

  class Menu
    hiv.mixin this, hiv.game.State

    constructor: (game) ->
      hiv.game.State.call this, game, "menu"
      @_input = @game.input
      @_renderer = @game.renderer
      @_locked = true
      @_scene = null
      @_welcome = null
      @_settings = null

    reset: ->
      hwidth = @game.settings.width / 2
      hheight = @game.settings.height / 2
      entity = null
      @_scene = new Scene(@game)

      @_welcome = @_scene.add(new hiv.ui.Tile(
        width: @game.settings.width
        height: @game.settings.height
        position:
          x: hwidth
          y: hheight
      ), null)

      @_scene.add new hiv.ui.Text(
        text: @game.settings.title
        font: @game.fonts.headline
        layout:
          position: "absolute"
          x: 0
          y: -hheight + 80
      ), @_welcome

      entity = new hiv.ui.Text(
        text: "Start Game"
        font: @game.fonts.normal
        layout:
          position: "absolute"
          x: 0
          y: -24
      )
      entity.bind "touch", ((entity) ->
        @game.setState "game"
      ), this
      @_scene.add entity, @_welcome

      entity = new hiv.ui.Text(
        text: "Settings"
        font: @game.fonts.normal
        layout:
          position: "absolute"
          x: 0
          y: 24
      )
      entity.bind "touch", ((entity) ->
        @_scene.scrollTo @_settings
      ), this
      @_scene.add entity, @_welcome

      @_settings = @_scene.add(new hiv.ui.Tile(
        width: @game.settings.width
        height: @game.settings.height
        position:
          x: hwidth * 3
          y: hheight
      ), null)
      entity = new hiv.ui.Text(
        text: "Settings"
        font: @game.fonts.headline
        layout:
          position: "absolute"
          x: 0
          y: -hheight + 80
      )
      entity.bind "touch", (entity) =>
        @_scene.scrollTo @_welcome
      @_scene.add entity, @_settings

      boolean = (flag) ->
        if flag then 'On' else 'Off'
      entity = new hiv.ui.Text
        text: "Music: #{boolean @game.settings.music}"
        font: @game.fonts.normal
        layout:
          position: "absolute"
          x: 0
          y: 24
      entity.bind "touch", (entity) =>
        @game.settings.music = !@game.settings.music
        entity.set "Music: #{boolean @game.settings.music}"
      @_scene.add entity, @_settings
      entity = new hiv.ui.Text
        text: "Sound: #{boolean @game.settings.sound}"
        font: @game.fonts.normal
        layout:
          position: "absolute"
          x: 0
          y: 72
      entity.bind "touch", (entity) =>
        @game.settings.sound = !@game.settings.sound
        entity.set "Sound:  #{boolean @game.settings.sound}"
      @_scene.add entity, @_settings

    enter: ->
      console.group 'Menu state'
      @reset()
      hiv.game.State::enter.call this
      @_locked = true
      @_scene.scrollTo @_welcome, =>
        @_locked = false
      @_input.bind "touch", @_processTouch, this

    leave: ->
      console.groupEnd()
      @_input.unbind "touch", @_processTouch
      hiv.game.State::leave.call this

    update: (clock, delta) ->
      @_scene.update clock, delta  if @_scene?

    render: (clock, delta) ->
      @_renderer.clear()
      @_scene.render clock, delta  if @_scene?
      @_renderer.flush()

    _processTouch: (id, position, delta) ->
      return  if @_locked
      entity = @_scene.getEntityByPosition(position.x, position.y, null, true)
      if entity?
        entity.trigger "touch", [entity]
