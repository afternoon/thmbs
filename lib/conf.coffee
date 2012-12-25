module.exports =
  redis:
    host: process.env.REDIS_HOST
    port: process.env.REDIS_PORT
    password: process.env.REDIS_PASSWORD
  port: 8000
  dropbox:
    app_key: "sjgwyizggdny3fh"
    app_secret: "1djaku4c64jhssq"
  oauthCallback: "http://thmbs.jit.su/oauth/callback"
