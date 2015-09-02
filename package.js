Package.describe({
  name: 'hitchcott:app-dump',
  version: '0.1.3',
  summary: 'In-app Backup and Restore for your Mongo Database',
  git: 'https://github.com/hitchcott/app-dump',
  documentation: 'README.md'
});

Npm.depends({
  "moment": "2.9.0",
  "formidable": "1.0.17",
  "busboy": "0.2.9",
  "mongodb-backup": "1.3.0",
  "mongodb-restore": "1.3.0"
});

Package.onUse(function(api) {

  api.versionsFrom('1.0.3.2');

  // SERVER
  api.use([
    'coffeescript',
    'iron:router@1.0.7'
  ], ['server'])

  api.addFiles([
    'app-dump-server.coffee'
  ], ['server']);


  // CLIENT
  api.use([
    'coffeescript',
    'templating'
  ], ['client'])

  api.addFiles([
    'app-dump-ui.html',
    'app-dump-ui.coffee'
  ], ['client']);

  api.export('appDump', ['server'])

});

// Package.onTest(function(api) {
//   api.use('tinytest');
//   api.use('ba-re');
//   api.addFiles('ba-re-tests.js');
// });
