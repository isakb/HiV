define ['hiv'], (hiv) ->

  class Renderer
    hiv.mixin this, hiv.ui.Renderer

    constructor: (id) ->
      hiv.ui.Renderer.call this, id

    moveCameraTo: (entity) ->
      offset = entity.getPosition()
      @camX = offset.x
      @camY = offset.y
      @centerX = @_width / 2
      @centerY = @_height / 2

    renderEntityBox: (entity, color, fill) ->
      {x, y, width, height} = entity.getBounds()
      @drawBox(
        @centerX - @camX + x,
        @centerY - @camY + y,
        @centerX - @camX + x + width,
        @centerY - @camY + y + height,
        color,
        fill,
        1
      )

    renderLayer: (layer, tileset, mapTileWidth, mapTileHeight) ->
      data = layer.data
      W = layer.width
      H = layer.height
      if layer.name is "collision"
        # TODO: Get from tileset
        color = "#f00"
        fill = false
        tileWidth = 32
        tileHeight = 32
      else
        # TODO: Get from tileset
        color = "#888"
        fill = true
        tileWidth = 16
        tileHeight = 16
      count = 0
      posY = 0
      for i in [0...H]
        posX = 0
        for j in [0...W]
          tile = data[count++]
          if tile
            @drawBox(
              @centerX - @camX + posX,
              @centerY - @camY + posY - tileHeight,
              @centerX - @camX + posX + tileWidth,
              @centerY - @camY + posY,
              color,
              fill
            )
          posX += mapTileWidth
        posY += mapTileHeight
