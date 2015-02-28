backup = Npm.require('mongodb-backup')
moment = Npm.require('moment')

appDump =
  allow: -> true

HTTP.methods
  'appDump': ->
    # TODO - security check on server
    if !appDump.allow.apply(@)
      @setStatusCode(401)
      console.log @
      return 'Access Denied.'
    else
      console.log 'success!', @userId
      safe =
        host: @requestHeaders.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
        app: process.env.PWD.split('/').pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
        date: moment().format("YY-MM-DD_HH-mm-ss")

      filename = "meteordump_#{safe.app}_#{safe.host}_#{safe.date}.tar"

      @addHeader 'Content-disposition', "attachment; filename=#{filename}"

      backup
        uri: process.env.MONGO_URL
        stream: @createWriteStream()
        tar: 'dump.tar'
