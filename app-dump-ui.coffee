templateHelpers =
  downloadToken : ->
    if Meteor.user()
      return Accounts?._storedLoginToken()

Template.appDumpDownload.helpers templateHelpers
Template.appDumpUpload.helpers templateHelpers

Template.appDumpDownload.events
  'click .app-dump-download' : (e) ->
    e.preventDefault()

    $form = $(e.currentTarget).closest 'form'

    collectionDumpUrl = '/appDump?'
    for dataItem in $form.serializeArray()
      if dataItem.value
        collectionDumpUrl += "&#{encodeURIComponent dataItem.name}=" + encodeURIComponent dataItem.value

    window.open collectionDumpUrl, collectionDumpUrl

Template.appDumpUpload.events
  'change .app-dump-upload' : (e) ->
    form = $(e.currentTarget).parent()[0]
    formData = new FormData(form)
    console.log 'got form data', JSON.stringify formData
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
