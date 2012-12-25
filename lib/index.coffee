dbox = require "dbox"
redis = require "redis"
conf = require "./conf"
app = require "./app"
users = require "./users"
thumbs = require "./thumbs"

db = redis.createClient conf.redis.port, conf.redis.host
db.on "error", (err) ->
  console.log "Redis Error: #{err}"
db.on "ready", (err) ->
  console.log "Connected to Redis instance #{conf.redis.host}:#{conf.redis.port}"
db.auth conf.redis.password

dbox_ = dbox.app conf.dropbox

users = new users.Users db

thumbClass = thumbs.Thumbs

app.run conf, dbox_, users, thumbClass
