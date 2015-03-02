templateHelpers =
  downloadToken : ->
    if Meteor.user()
      return Accounts?._storedLoginToken()

Template.appDumpDownload.helpers templateHelpers
Template.appDumpUpload.helpers templateHelpers

Template.appDumpUpload.events
  'change .app-dump-upload' : (e) ->
    form = $(e.currentTarget).parent()[0]
    formData = new FormData(form)

    $.ajax
      type: "POST"
      url: '/appDump'
      data: formData
      cache: false
      enctype: 'multipart/form-data'
      contentType: false
      processData: false
    .done (data) ->
      alert 'Restore Complete'
    .fail (err) ->
      alert err.responseText
