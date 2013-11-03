console.groupCollapsed('Loading AMD modules')

requirejs.config
  waitSeconds: 10
  enforceDefine: true
  paths:
    Q: '../vendor/q/q'
    lodash: "../vendor/components/lodash/dist/lodash"
  packages: [
    {
      name: "hiv"
      location: "../vendor/hiv"
      main: "main"
    }
  ]
define (require) ->
  require ["./GameApp"], (GameApp) ->

    console.groupEnd()

    window.game = new GameApp(
      width: 800
      height: 600
      background: '#abc'
    )
    window.game.bind 'ready', ->
      window.document.documentElement.className += " game-loaded";

  return
