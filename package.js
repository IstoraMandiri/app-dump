Package.describe({
  name: 'hitchcott:app-dump',
  version: '0.4.2',
  summary: 'In-app Backup and Restore for your Mongo Database',
  git: 'https://github.com/hitchcott/app-dump',
  documentation: 'README.md'
});

Npm.depends({
  "moment": "2.9.0",
  "busboy": "0.2.11",
  "mongodb-backup": "1.4.2",
  "mongodb-restore": "1.4.2"
});

Package.onUse(function(api) {

  api.versionsFrom('1.0.3.2');

  // SERVER
  api.use([
    'check',
    'coffeescript',
    'iron:router@1.0.7' // for REST endpoint only
  ], ['server'])

  api.addFiles([
    'app-dump-server.coffee'
  ], ['server']);


  // CLIENT
  api.use([
    'coffeescript',
    'templating',
    'less@2.5.1',
    'reactive-var'
  ], ['client'])

  api.addFiles([
    'app-dump-ui.html',
    'app-dump-ui.coffee',
    'app-dump-ui.less'
  ], ['client']);

  api.export('appDump', ['server'])

});
