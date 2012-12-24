dbox = require "dbox"
redis = require "redis"
conf = require "./conf"
app = require "./app"

dboxApp = dbox.app conf.dropbox

db = redis.createClient()

app.run conf, db, dboxApp
