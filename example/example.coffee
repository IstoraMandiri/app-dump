test = new Mongo.Collection 'testing'

if Meteor.isServer
  appDump.allow = ->
    # do your own auth here -- eg. check if user is an admin...
    # if @user?.admin
    return true

if Meteor.isClient
  Template.test.events
    'click .add' : ->
      test.insert {date: new Date()}

  Template.test.helpers
    items: -> test.find()