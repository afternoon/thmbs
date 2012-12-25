dbox = require "dbox"
redis = require "redis"
conf = require "./conf"
app = require "./app"
users = require "./users"
thumbs = require "./thumbs"

db = redis.createClient()
db.on "error", (err) -> console.log "Redis Error: #{err}"
users = new users.Users db

dbox_ = dbox.app conf.dropbox
thumbClass = thumbs.Thumbs

app.run conf, dbox_, users, thumbClass
