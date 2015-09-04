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


      if req.method is 'GET'
        req.query.parser?= ''
        check req.query.parser, String

        self.options =
          parser: req.query.parser

        # parse the collections
        if req.query.collections
          check req.query.collections, String

          # convert commas into array
          self.options.collections = req.query.collections.split(',').map (col) -> col.trim()

          if self.options.collections.length is 0
            self.options.collections = null

        # parse the query
        if req.query.query
          check req.query.query, String
          try
            self.options.query = JSON.parse req.query.query
          catch e
            res.statusCode = 401
            res.end "Failed to parse JSON Query"
            return false


        # add the token
        token = req.query.token || ''
        check token, String
        self.user = Meteor.users.findOne({"services.resume.loginTokens.hashedToken": Accounts._hashLoginToken(token)});

        if !appDump.allow.apply self
          res.statusCode = 401
          res.end 'Unauthorized'
          return false

        safe =
          host: req.headers.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
          app: process.env.PWD.split('/').pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
          date: moment().format("YY-MM-DD_HH-mm-ss")
          parser: self.options.parser || 'bson'

        filename = "meteordump_#{safe.parser}_#{safe.app}_#{safe.host}_#{safe.date}.tar"

        res.statusCode = 200
        res.setHeader 'Content-disposition', "attachment; filename=#{filename}"

        backupOptions =
          uri: process.env.MONGO_URL
          stream: res
          tar: 'dump.tar'
          query: self.options.query
          parser: self.options.parser

        if self.options.collections
          backupOptions.collections = self.options.collections

        backup backupOptions


      if req.method is 'POST'

        busboy = new Busboy
          headers: req.headers
          limits:
            fields:2
            files:1

        token = undefined
        self.options = drop: false

        busboy.on "field", (fieldname, val) ->
          if fieldname is 'token'
            token = val
          if fieldname is 'drop'
            self.options.drop = true

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

          restoreOptions =
            uri: process.env.MONGO_URL
            stream: file
            drop: self.options.drop
            callback : -> res.end()

          restore restoreOptions

        req.pipe busboy


