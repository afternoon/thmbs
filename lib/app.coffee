sys = require "sys"
connect = require "connect"
jade = require "jade.plugin"
flatiron = require "flatiron"

# setup app
app = flatiron.app
app.use flatiron.plugins.http, before: [
  connect.cookieParser(),
  connect.cookieSession(key: "thmbs_session", secret: "thmbs_session_20121224"),
  connect.favicon(),
  connect.logger('dev'),
  connect.static("public")
]
app.use jade.plugin, dir: __dirname + "/views", ext: ".jade"

# index page
app.router.get "/", -> app.render @res, "index"

# start oauth signin process
app.router.get "/oauth/signin", ->
  app.dbox.requesttoken (status, reqToken) =>
    @req.session.reqToken = reqToken
    url = "#{reqToken.authorize_url}&oauth_callback=#{app.conf.oauthCallback}"
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
  app.users.set username, @req.session.accToken
  @res.redirect "/#{username}"

# user profile page
app.router.get "/:username", (username) ->
  withUser app, @res, username, (user) =>
    console.log "/#{username}", user
    thumbs = new app.thumbClass username, app.dbox.client user
    thumbs.sets (err, sets) =>
      if err?
        @res.writeHead 500
        @res.end "Error getting sets: #{err.data}"
      else
        console.log "sets", sets
        app.render @res, "profile", {username, sets}

# get thumbnail for set (path like /afternoon/india/thumb.jpg)
app.router.get /([^\/]+)\/([^\/]+)\/thumb\.jpg/, (username, path) ->
  withUser app, @res, username, (user) =>
    console.log "/#{username}", user
    thumbs = new app.thumbClass username, app.dbox.client user
    thumbs.thumbnail path, (err, thumbnail, metadata) =>
      if err?
        console.log "thumbnail response", err
        @res.writeHead 500
        @res.end "Error getting set thumbnail: #{err}"
      else
        @res.end thumbnail

withUser = (app, res, username, callback) ->
  app.users.get username, (err, user) =>
    if user?
      callback user
    else
      res.writeHead 404
      res.end "User #{username} not found"

# run application
run = (conf, dbox, users, thumbClass) ->
  app.conf = conf
  app.dbox = dbox
  app.users = users
  app.thumbClass = thumbClass
  app.start conf.port

module.exports = {run}
