sys = require "sys"
connect = require "connect"
jade = require "jade.plugin"
flatiron = require "flatiron"

# setup app
app = flatiron.app
app.use flatiron.plugins.http, before: [
  connect.static("public"),
  connect.cookieParser(),
  connect.cookieSession(key: "thmbs_session", secret: "thmbs_session_20121224")
]
app.use jade.plugin, dir: __dirname + "/views", ext: ".jade"

# index page
app.router.get "/", -> app.render @res, "index"

# start oauth signin process
app.router.get "/oauth/signin", ->
  app.dbox.requesttoken (status, reqToken) =>
    @req.session.reqToken = reqToken
    url = "#{reqToken.authorize_url}&oauth_callback=#{app.conf.oauthCallback}"
    console.log "Redirecting to #{url}"
    @res.redirect url, 303

# complete oauth signin
app.router.get "/oauth/callback", ->
  @res.redirect "/oauth/signin", 303 unless @req.session.reqToken?
  app.dbox.accesstoken @req.session.reqToken, (status, accToken) =>
    @req.session.accToken = accToken
    @res.redirect "/profile/create", 303

# create new profile (pick username, etc)
app.router.get "/profile/create", -> app.render @res, "profileCreate"

# create profile in DB
app.router.post "/profile/create", ->
  username = @req.body.username
  console.log "Got username #{username}"
  app.db.hmset username, @req.session.accToken
  @res.redirect "/#{username}"

# user profile page
app.router.get "/:username", (username) ->
  app.db.hgetall username, (err, obj) =>
    if err or obj is null
      @res.writeHead 404
      @res.end "User #{username} not found"
    else
      client = app.dbox.client obj
      client.account (status, reply) =>
        @res.end sys.inspect reply

# run application
run = (conf, db, dbox) ->
  app.conf = conf
  app.db = db
  app.dbox = dbox
  app.start conf.port

module.exports = {run}
