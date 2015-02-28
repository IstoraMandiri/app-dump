Package.describe({
  name: 'hitchcott:app-dump',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'Backup-Restore your Database',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {

  api.versionsFrom('1.0.3.2');

  // SERVER + CLIENT
  api.use([
    'coffeescript'
  ], ['client', 'server'])

  // SERVER
  Npm.depends({
    "moment": "2.9.0",
    "mongodb-backup": "https://github.com/hex7c0/mongodb-backup/archive/681ea44bd9946dbf9d2ca7560362a60d199b0959.tar.gz"
  });

  api.use([
    'cfs:http-methods'
  ], ['server'])

  api.addFiles([
    'app-dump.coffee'
  ], ['server']);

  // CLIENT
  api.use([
    'templating'
  ], ['client'])

  api.addFiles([
    'ui/app-dump-ui.html',
    'ui/app-dump-ui.coffee'
  ], ['client']);

  api.export('appDump', 'server')

});


// Package.onTest(function(api) {
//   api.use('tinytest');
//   api.use('ba-re');
//   api.addFiles('ba-re-tests.js');
// });
