Template.appDumpUI.helpers
  downloadToken : ->
    if Meteor.user()
      return Accounts?._storedLoginToken()