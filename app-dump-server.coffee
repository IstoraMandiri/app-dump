backup = Npm.require('mongodb-backup')
restore = Npm.require('mongodb-restore')
moment = Npm.require('moment')
Busboy = Npm.require("Busboy")
fs = Npm.require('fs')

appDump =
  allow: -> true

Router.map ->
  @route 'appDumpHTTP',
    path: '/appDump',
    where: 'server',
    action: ->
      req = @request
      res = @response

      token = if req.method is 'GET' then req.query.token else req.body.token
      token?= ''
      @user = Meteor.users.findOne({"services.resume.loginTokens.hashedToken": Accounts._hashLoginToken(token)});

      if !appDump.allow.apply(@)
        res.statusCode = 401
        res.end 'Unauthorized'
        return false

      if req.method is 'GET'

        safe =
          host: req.headers.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
          app: process.env.PWD.split('/').pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
          date: moment().format("YY-MM-DD_HH-mm-ss")

        filename = "meteordump_#{safe.app}_#{safe.host}_#{safe.date}.tar"


        res.statusCode = 200
        res.setHeader 'Content-disposition', "attachment; filename=#{filename}"

        backup
          uri: process.env.MONGO_URL
          stream: res
          tar: 'dump.tar'

      if req.method is 'POST'
        busboy = new Busboy headers: req.headers
        busboy.on "file", (fieldname, file, filename, encoding, mimetype) ->

          unless filename.split('.').pop() is 'tar'
            res.statusCode = 400
            res.end 'Incorrect file type. Expecting a file ending in .tar'

          restore
            uri: process.env.MONGO_URL
            stream: file
            drop: true
            callback : -> res.end()

        req.pipe busboy