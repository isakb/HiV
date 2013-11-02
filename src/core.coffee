root = this

define ->

  extend = (obj, mixin) ->
    obj[name] = method for name, method of mixin
    obj

  hivBefore = root.hiv
  root.hiv = {

    root: root

    audio: {}

    browser: {}

    game: {}

    ui: {}

    extend: (obj, objs...) ->
      for obj2 in objs
        extend(obj, obj2)  if obj2
      obj

    mixin: (klass, mixins...) ->
      klass.prototype or= {}
      for obj in mixins
        extend klass.prototype, obj.prototype

    noConflict: ->
      root.hiv = hivBefore
      this

    isArray : (x) -> Array.isArray(x)

    isObject: (x) -> Object(x) is x

  }
