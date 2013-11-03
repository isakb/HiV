define [
  "hiv"
  "./Renderer"
  "./state/Game"
  "./state/Menu"
], (hiv, GameRenderer, GameState, MenuState) ->
  console.info 'Game loaded'

  class GameApp
    hiv.mixin this, hiv.Events

    defaults:
      title: "Example Sidescroller"
      sound: true
      music: true
      fullscreen: false
      loaderTimeout: 15000
      width: 320
      height: 240
      background: false

    constructor: (settings) ->
      hiv.Events.call this, "game"
      @_isLoaded = false
      @data = {} # Loaded assets will be available here
      @settings = hiv.extend(@defaults, settings)
      @input = new hiv.platform.Input(
        delay: 0
        fireModifier: false
        fireKey: true
        fireTouch: true
        fireSwipe: false
      )
      @viewport = new hiv.platform.Viewport()
      @renderer = new GameRenderer("game")

      @states =
        game: new GameState(this)
        menu: new MenuState(this)

      @fonts =
        headline: 'italic 50pt Arial'
        normal:'30pt Arial'
        small: '16pt Arial'
      @loop = new hiv.game.Loop()
      @loop.bind 'update', (t, dt) => @_state.update(t, dt)
      @loop.bind 'render', (t, dt) => @_state.render(t, dt)
      @assets =
        levels:
          "01": 'asset/json/l01.json'
        entities:
          "bullet": 'asset/json/bullet.json'
      @preload().then (assets) => setTimeout => @onLoadDone(assets)

    preload: ->
      urls = []
      for category, categoryUrls of @assets
        for key, url of categoryUrls
          urls.push url
      console.debug 'Loading assets:', urls
      new hiv.Preloader(@settings.loaderTimeout).load urls

    onLoadDone: (assets) =>
      @_isLoaded = true
      @trigger 'ready'
      console.log 'Load done', assets
      for category, categoryAssets of @assets
        for key, url of categoryAssets
          categoryAssets[key] = assets[url]
      @data.player = {}
      (@data[category] = @assets[category]) for category of @assets
      @init()

    getLoop: ->
      @loop

    getInput: ->
      @input

    getRenderer: ->
      @renderer

    getAssets: (category = null) ->
      throw new Error('Please preload assets')  unless @_isLoaded
      if category
        @data[category]
      else
        @data

    reset: ->
      env = @renderer.getEnvironment()
      {width, height} = env
      if typeof width is "number" and typeof height is "number"
        env.screen.width = width
        env.screen.height = height
      if @settings.fullscreen
        @settings.width = env.screen.width
        @settings.height = env.screen.height
      else
        @settings.width = @defaults.width
        @settings.height = @defaults.height
      @renderer.reset @settings.width, @settings.height, false
      @_offset = env.offset # Linked

    init: ->
      @renderer.reset @settings.width, @settings.height, true
      @renderer.setBackground @settings.background  if @settings.background
      @viewport.bind "reshape", ((orientation, rotation, width, height) ->
        @reset width, height
        for id of @states
          @states[id].reset()
        state = @getState()
        state.leave?()
        state.enter?()
      ), this
      @viewport.bind "hide", => @stop()
      @viewport.bind "show", => @start()
      @reset()
      @setState(
        if localStorage?.gameState?
          localStorage.gameState
        else
          "menu"
      )
      @loop.start()


    getOffset: ->
      @_offset

    getState: (id = null) ->
      @states[id] or @_state

    setState: (id, data = null) ->
      oldState = @_state
      newState = @states[id] or null

      return false  unless newState?
      oldState?.leave?()
      newState.enter?(data)
      @_state = newState
      localStorage?.gameState = id
      true
