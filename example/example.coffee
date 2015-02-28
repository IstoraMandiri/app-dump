if Meteor.isServer
  appDump.allow = ->
    # do your own auth here -- eg. check if user is an admin...
    if @userId?
      return true