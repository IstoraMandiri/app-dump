# Metoer App-Dump

### A Simple In-App Backup/Restore solution for Meteor

Example: http://app-dump-example.meteor.com/, or check the `/example` folder

Generates a downloadable tar backup of the current mongo database, which can be uploaded to restore.

Use `{{> appDumpUI}}` to add download and upload UI to your template.

Secure the download and upload method on the server:

```
if Meteor.isServer
  appDump.allow = ->
    # do your own auth here -- eg. check if user is an admin...
    if @user?.admin
      return true
```

:exclamation: I have experienced an issue with large grid-fs collections being restored while writes are occuring. This is being looked in to. In the meantime use `mongodump` for mission critical operations.

:warning: Restoring a backup will destroy existing data.

:thumbsup: Works on meteor.com hosting.


## What's wrong with [`hitchcott:backup-restore`](https://github.com/hitchcott/meteor-backup-restore/)?

It doesn't work with the meteor.com deployment servers because it requires MongoDB to be installed on the host system. 

`hitchcott:app-dump` uses a pure node implementation, so does not require `mongodump` or `mongorestore`. It also uses streams for serving the tar, so it's a bit more efficient and secure.


## TODO

Tests

## Author

Chris Hitchcott, 2014

MIT License

## Thanks to

[hex7c0](https://github.com/hex7c0) for creating [mongodb-backup](https://github.com/hex7c0/mongodb-backup) and [mongodb-restore](https://github.com/hex7c0/mongodb-restore)
