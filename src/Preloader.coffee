define ['Q'], (Q) ->

  class Preloader
    constructor: (@_timeout = 3000) ->

    load: (urls, types = urls.map(@getFileType)) ->
      urls = [urls] unless Array.isArray(urls)
      urlPromises = urls.map (url) =>
        @loadUrl(url)
          .then (data) ->
            [url, data]
      Q.all(urlPromises)
        .then (loaded) ->
          obj = {}
          for [url, data] in loaded
            obj[url] = data
          obj

    loadUrl: (url, type = @getFileType(url)) ->
      dfd = Q.defer()
      @loaders[type](url, dfd)
      dfd.promise.timeout @_timeout, "Timeout for #{url} after #{@_timeout} ms"

    loaders:
      json: (url, dfd) ->
        xhr = new XMLHttpRequest()
        xhr.open 'GET', url, true
        xhr.setRequestHeader 'Content-Type', 'application/json; charset=utf8'
        xhr.onreadystatechange = ->
          if xhr.readyState is 4
            try
              data = JSON.parse(xhr.responseText)
            catch e
              dfd.reject "Could not parse JSON at #{url}: #{e}"
              return
            dfd.resolve data
        xhr.send null

      image: (url, dfd) ->
        img = new Image()
        img.onload = ->
          dfd.resolve(this)
        img.src = url

      other: (url, dfd) ->
        xhr = new XMLHttpRequest()
        xhr.open 'GET', url, true
        xhr.onreadystatechange = ->
          if xhr.readyState is 4 and xhr.status is 200 or xhr.status is 304
            dfd.resolve xhr.responseText or xhr.responseXML or null
        xhr.send null

    getFileType: (path) ->
      [dontcare..., extension] = path.split(/\./)
      switch extension
        when 'json'
          'json'
        when 'bmp', 'gif', 'jpg', 'jpeg', 'png'
          'image'
        else
          'other'
