// Copyright (c) 2017, Jonah Williams. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:args/command_runner.dart';

import 'package:angular_cli/angular_cli.dart' as angular_cli;

final runner = new CommandRunner(
    'angular_cli', 'a command line interface for Angular Dart')
  ..addCommand(new ScaffoldCommand());

void main(List<String> arguments) {
  Logger.root.onRecord.listen((record) {
    print(record);
  });
  runner.run(arguments);
}

/// A command for scaffolding a new angular component and associated tests.
class ScaffoldCommand extends Command {
  static final _logger = new Logger('scaffold');

  ScaffoldCommand() {
    argParser
      ..addFlag('include_tests',
          abbr: 't',
          help: 'whether to include a test subdirectory',
          defaultsTo: true)
      ..addOption('name',
          abbr: 'n',
          help: 'The HTML name of the component to generate.',
          defaultsTo: 'my-component');
  }

  @override
  String get description =>
      'Creates a new Angular Component and associated scaffolding';

  @override
  String get name => 'scaffold';

  Future<Null> run() async {
    var config = new angular_cli.Config()
      ..preserveWhitespace = false
      ..name = argResults['name'];

    _logger.info('Writing scaffold for ${config.name}...');

    var filename = angular_cli.kebabToSnake(config.name);
    var cssFile = new File('${filename}.css');
    var htmlFile = new File('${filename}.html');
    var dartFile = new File('${filename}.dart');

    _logger.info('creating dart, html, and css files...');
    List<File> files;
    try {
      files = await Future.wait([
        cssFile.create(),
        htmlFile.create(),
        dartFile.create(),
      ]);
    } on FileSystemException catch (err) {
      _logger.severe('Failed to create files: ${err}');
      return;
    }

    await files.last.writeAsString(angular_cli.buildComponent(config));

    _logger.info('created component class');

    if (argResults['include_tests']) {
      _logger.info('creating test folder...');
      var testFolder = await new Directory('test').create();

      var testFile = await new File('test/$filename.test.dart').create();
      await testFile.writeAsString(angular_cli.buildTest(config));
    }
    _logger.info('All Done!');
  }
}
