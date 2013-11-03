define ['./core'], (hiv) ->
  console.info 'Events loaded'

  Events = class hiv.Events
    @instanceCount = 0

    constructor: (@_namespace) ->
      Events.instanceCount += 1
      @_id = Events.instanceCount
      @_events = {}

    bind: (type, callback, context = null) ->
      @_events[type] or= []
      @_events[type].push
        callback: callback
        context: context
      this

    unbind: (type, callback, context = null) ->
      return true  unless @_events[type]
      matches = []
      for entry, index in @_events[type]
        isMatch =
          (not callback or entry.callback is callback) and
          (not context or entry.context is context)
        if isMatch
          matches.push(index)
      for index in matches
        @_events[type].splice(index, 1)
      this

    trigger: (type, data) ->
      data ?= {}
      data._handled or= {}
      if data._handled[@_id] is true
        null
      else
        @_trigger(type, data)

    _trigger: (type, data) ->
      blocked = false
      if data isnt undefined
        data._handled[@_id] = true
      if @_events[type]
        for entry in @_events[type]
          if entry.callback.apply(entry.context, data) is true
            blocked = true
      !!blocked
