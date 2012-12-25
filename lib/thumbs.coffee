async = require "async"

class Thumbs
  constructor: (@username, @client) ->

  sets: (callback) ->
    @client.metadata "/", {}, (status, data) =>
      if status != 200
        callback {status, data}
      else
        console.log "Thumbs.sets", data
        sets = data.contents.filter((x) -> x.is_dir).map (x) =>
          thumbnailUrl: "/#{@username}#{x.path}/thumb.jpg"
        callback undefined, sets

  thumbnail: (path, callback) ->
    @client.search path, "jpg", file_limit: 1, (status, data) =>
      if status != 200
        callback {status, data}
      else
        @client.thumbnails data[0].path, (status, data, metadata) =>
          if status != 200
            callback {status, data}
          else
            callback undefined, data, metadata

module.exports = {Thumbs}
