# Metoer App-Dump

### A Simple In-App Backup/Restore solution for Meteor

Generates a tar backup of the mongo collection on demand, which can be uploaded to restore.

Use `{{> appDumpUI}}` to add upload/download UI to your template.

Secure the upload method on the server:

```
if Meteor.isServer
  appDump.allow = ->
    # do your own auth here -- eg. check if user is an admin...
    if @user?.admin
      return true
```

:warning: Restoring a backup will destroy existing data.

:thumbsup: Should work on meteor.com hosting

## TODO

Tests

## Author

Chris Hitchcott, 2014

## Thanks to

[hex7c0](https://github.com/hex7c0) for creating [mongodb-backup](https://github.com/hex7c0/mongodb-backup) and [mongodb-restore](https://github.com/hex7c0/mongodb-restore)
