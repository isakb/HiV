define (require, exports, module) ->
  console.info 'HiV main.coffee'

  hiv                 = require './core'
  hiv.Preloader       = require './Preloader'
  hiv.Events          = require './Events'
  hiv.game.Loop       = require './game/Loop'

  module.exports = hiv
