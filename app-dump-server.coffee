backup = Npm.require('mongodb-backup')
restore = Npm.require('mongodb-restore')
moment = Npm.require('moment')
Busboy = Npm.require("busboy")
fs = Npm.require('fs')

appDump =
  allow: -> true

Router.map ->
  @route 'appDumpHTTP',
    path: '/appDump',
    where: 'server',
    action: ->
      self = @
      req = @request
      res = @response

      mongoCollections = null
      mongoQuery = null
      mongoDrop = true
      requestedFilename = null 

      for param in req._parsedUrl.query.split('&')
        key = param.substring(0,2)
        value = param.substring(2)
        if key is 'c=' then mongoCollections = value.replace(/\s+/g, '').split(',')
        if key is 'q=' then mongoQuery = value
        if key is 'd=' then mongoDrop = value
        if key is 'f=' then requestedFilename = value

      if req.method is 'GET'
        token = req.query.token || ''
        self.user = Meteor.users.findOne({"services.resume.loginTokens.hashedToken": Accounts._hashLoginToken(token)});

        if !appDump.allow.apply self
          res.statusCode = 401
          res.end 'Unauthorized'
          return false

        safe =
          host: req.headers.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
          app: process.env.PWD.split('/').pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
          date: moment().format("YY-MM-DD_HH-mm-ss")

        if requestedFilename is null
          filename = "meteordump_#{safe.app}_#{safe.host}_#{safe.date}.tar"
        else
          filename = requestedFile

        res.statusCode = 200
        res.setHeader 'Content-disposition', "attachment; filename=#{filename}"

        bOpts =
          uri: process.env.MONGO_URL
          stream: res
          tar: 'dump.tar'

        if mongoQuery isnt null then bOpts.query = mongoQuery
        if mongoCollections isnt null then bOpts.collections = mongoCollections

        backup bOpts


      if req.method is 'POST'
        busboy = new Busboy
          headers: req.headers
          limits:
            fields:1
            files:1

        token = undefined

        busboy.on "field", (fieldname, val) ->
          if fieldname is 'token'
            token = val

        busboy.on "file", Meteor.bindEnvironment (fieldname, file, filename) ->
          if fieldname isnt 'appDumpUpload' or filename.split('.').pop() isnt 'tar'
            res.statusCode = 400
            res.end 'Incorrect file type. Expecting a file ending in .tar'
            return false

          unless file?
            res.statusCode = 400
            res.end 'File not found'
            return false

          self.user = Meteor.users.findOne({"services.resume.loginTokens.hashedToken": Accounts._hashLoginToken(token)})

          if !appDump.allow.apply(self)
            res.statusCode = 401
            res.end 'Unauthorized'
            return false

          rOpts =
            uri: process.env.MONGO_URL
            stream: file
            drop: mongoDrop
            callback : -> res.end()

          restore rOpts

        req.pipe busboy


