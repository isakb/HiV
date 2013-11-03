root = this

define ->

  isArray = (x) -> Array.isArray(x)

  isObject = (x) -> Object(x) is x

  copy = (obj) ->
    if isArray(obj)
      obj.slice(0)
    else if isObject(obj)
      extendOne({}, obj)
    else
      obj

  extend = (obj, objs...) ->
    for obj2 in objs
      extendOne(obj, obj2)  if obj2
    obj

  extendOne = (obj, mixin) ->
    obj[name] = method for name, method of mixin
    obj

  mixin = (klass, mixins...) ->
    klass.prototype or= {}
    for obj in mixins
      extendOne klass.prototype, obj.prototype


  hivBefore = root.hiv

  root.hiv = {

    root

    copy
    extend
    mixin

    isArray
    isObject

    audio: {}
    browser: {}
    game: {}
    ui: {}

    noConflict: ->
      root.hiv = hivBefore
      this
  }
