define ['hiv'], (hiv) ->

  class Scene
    hiv.mixin this, hiv.ui.Graph

    constructor: (game) ->
      hiv.ui.Graph.call this, game.renderer

    scrollTo: (node, callback, scope) ->
      entity = node?.entity
      if entity?
        position = entity.getPosition()
        @setTween 300,
          x: -1 * (position.x - entity.width / 2)
          y: -1 * (position.y - entity.height / 2)
        , callback, scope
