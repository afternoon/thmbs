class Users
  constructor: (@db) ->

  set: (username, params) ->
    @db.hmset username, params

  get: (username, callback) ->
    @db.hgetall username, (err, data) ->
      callback err, data

module.exports = {Users}
