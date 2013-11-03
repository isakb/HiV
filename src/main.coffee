define (require, exports, module) ->
  console.info 'HiV main.coffee'

  hiv                 = require './core'
  hiv.Preloader       = require './Preloader'

  module.exports = hiv
