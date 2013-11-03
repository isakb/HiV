define ['../core'], (hiv) ->
  console.info 'browser/CanvasRenderer loaded'

  {root} = hiv
  doc = root.document

  class CanvasRenderer
    @isSupported = -> !!root.CanvasRenderingContext2D

    constructor: (@_id = null) ->
      @_canvas = doc.getElementById(@_id) ? doc.createElement("canvas")
      @_ctx = @_canvas.getContext("2d")
      @_environment =
        width: null
        height: null
        screen: {}
        offset: {}
      @_alpha = 1
      @_background = null
      @_width = 0
      @_height = 0

      @context = @_canvas
      @_canvas.id = @_id  if @_id?
      doc.body.appendChild @_canvas  unless @_canvas.parentNode
      this

    reset: (width = @_width, height = @_height, resetCache = false) ->
      canvas = @_canvas
      @_width = width
      @_height = height
      canvas.width = width
      canvas.height = height
      canvas.style.width = width + "px"
      canvas.style.height = height + "px"
      @_updateEnvironment()
      this

    clear: ->
      ctx = @_ctx
      canvas = @_canvas
      ctx.fillStyle = @_background
      ctx.fillRect 0, 0, canvas.width, canvas.height
      this

    flush: ->
      this

    getEnvironment: ->
      @_updateEnvironment()
      @_environment

    setAlpha: (alpha = 1) ->
      if alpha? and 0 <= alpha <= 1
        @_ctx.windowAlpha = alpha
      this

    setBackground: (color = "#000000") ->
      @_background = color
      @_canvas.style.backgroundColor = color
      this

    drawText: (x, y, text,
               font = null,
               color = '#ffffff',
               background = false,
               lineWidth = 1) ->
      x |= 0
      y |= 0
      ctx = @_ctx
      ctx.textAlign = 'center'
      ctx.font = font
      ctx.beginPath()
      if not background
        ctx.lineWidth = lineWidth
        ctx.strokeStyle = color
        ctx.strokeText text, x, y
      else
        ctx.fillStyle = color
        ctx.fillText text, x, y
      ctx.closePath()
      this

    drawBox: (x1, y1, x2, y2,
              color = "#000000",
              background = false,
              lineWidth = 1) ->
      x1 |= 0
      y1 |= 0
      x2 |= 0
      y2 |= 0
      ctx = @_ctx
      if not background
        ctx.lineWidth = lineWidth
        ctx.strokeStyle = color
        ctx.strokeRect x1, y1, x2 - x1, y2 - y1
      else
        ctx.fillStyle = color
        ctx.fillRect x1, y1, x2 - x1, y2 - y1
      this

    drawCircle: (x, y, radius,
                 color = "#000000",
                 background = false,
                 lineWidth = 1) ->
      x |= 0
      y |= 0
      ctx = @_ctx
      ctx.beginPath()
      ctx.arc x, y, radius, 0, Math.PI * 2
      if background is false
        ctx.lineWidth = lineWidth
        ctx.strokeStyle = color
        ctx.stroke()
      else
        ctx.fillStyle = color
        ctx.fill()
      ctx.closePath()
      this

    drawLine: (x1, y1, x2, y2,
               color = "#000000",
               lineWidth = 1) ->
      x1 |= 0
      y1 |= 0
      ctx = @_ctx
      ctx.beginPath()
      ctx.moveTo x1, y1
      ctx.lineTo x2, y2
      ctx.lineWidth = lineWidth
      ctx.strokeStyle = color
      ctx.stroke()
      ctx.closePath()
      this

    _updateEnvironment: ->
      env = @_environment
      env.screen.width = root.innerWidth
      env.screen.height = root.innerHeight
      env.offset.x = @_canvas.offsetLeft
      env.offset.y = @_canvas.offsetTop
      env.width = @_width
      env.height = @_height
      this
