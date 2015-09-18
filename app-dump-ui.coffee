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

    window.location.href = collectionDumpUrl

Template.appDumpUpload.onCreated ->
  @uploading = new ReactiveVar false

Template.appDumpUpload.helpers
  uploading: ->
    Template.instance().uploading.get()

Template.appDumpUpload.events
  'change .app-dump-upload' : (e, tmpl) ->
    $form = $(e.currentTarget).closest 'form'
    tmpl.uploading.set true
    $.ajax
      type: "POST"
      url: '/appDump'
      data: new FormData($form[0])
      cache: false
      enctype: 'multipart/form-data'
      contentType: false
      processData: false
    .done (data) ->
      alert 'Restore Complete'
    .fail (err) ->
      alert err.responseText
    .always ->
      tmpl.uploading.set false
