backup = Npm.require('mongodb-backup')
restore = Npm.require('mongodb-restore')
moment = Npm.require('moment')
fs = Npm.require('fs')

appDump =
  allow: -> true

Router.map ->
  @route 'appDumpHTTP',
    path: '/appDump',
    where: 'server',
    action: ->
      token = if @request.method is 'GET' then @request.query.token else @request.body.token
      token?= ''
      @user = Meteor.users.findOne({"services.resume.loginTokens.hashedToken": Accounts._hashLoginToken(token)});

      if !appDump.allow.apply(@)
        @response.statusCode = 401
        @response.end 'Unauthorized'
        return false

      if @request.method is 'GET'

        safe =
          host: @request.headers.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
          app: process.env.PWD.split('/').pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
          date: moment().format("YY-MM-DD_HH-mm-ss")

        filename = "meteordump_#{safe.app}_#{safe.host}_#{safe.date}.tar"


        @response.statusCode = 200
        @response.setHeader 'Content-disposition', "attachment; filename=#{filename}"

        backup
          uri: process.env.MONGO_URL
          stream: @response
          tar: 'dump.tar'

      if @request.method is 'POST'
        file = @request.files.appDumpUpload

        unless file?.name.split('.').pop() is 'tar'
          @response.statusCode = 400
          @response.end 'Incorrect file type. Expecting a file ending in .tar'

        # TODO use direct stream?
        stream = fs.createReadStream(@request.files.appDumpUpload.path)

        restore
          uri: process.env.MONGO_URL
          stream: stream
          drop: true

        @response.end()