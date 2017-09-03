// Copyright (c) 2017, Jonah Williams. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:charcode/charcode.dart';

/// Converts a kebab-cases selector name into a camelCase class name.
///
/// This does not validate that the result is a legal Dart identifier or
/// html selector.
String kebabToCamel(String value) {
  var buffer = new StringBuffer();
  bool capitalizeNext = true;
  for (var codeUnit in value.trim().codeUnits) {
    if (codeUnit == $dash) {
      capitalizeNext = true;
    } else if (capitalizeNext) {
      capitalizeNext = false;
      if (codeUnit >= $a && codeUnit <= $z) {
        buffer.writeCharCode(codeUnit - 32);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    } else {
      buffer.writeCharCode(codeUnit);
    }
  }
  buffer.write('Component');
  return buffer.toString();
}

/// Converts a kebab-case selector name to a snake_case file name.
///
/// Does not validate either the selector or the resulting file name.
String kebabToSnake(String value) {
  return value.replaceAll('-', '_');
}

/// Builds a component template.
String buildComponent(Config config) {
  var selectorName = config.name;
  var className = kebabToCamel(selectorName);
  var filename = kebabToSnake(selectorName);

  return '''
  import 'package:angular/angular.dart';

  /// Todo: write a description.
  @Component(
    selector: '$selectorName',
    templateUrl: '${filename}.html',
    styleUrls: const [
      '${filename}.css'
    ],
    changeDetection: ChangeDetectionStrategy.Default,
    preserveWhitespace: ${config.preserveWhitespace},
  )
  class $className {}
  ''';
}

String buildTest(Config config) {
  var selectorName = config.name;
  var className = kebabToCamel(selectorName);
  var filename = kebabToSnake(selectorName);

  return '''
  @Tags(const ['aot'])
  @TestOn('browser')
  import 'dart:html';
  import 'package:angular/angular.dart';
  import 'package:angular_test/angular_test.dart';
  import 'package:test/test.dart';
  import '../${filename}.dart';

  @AngularEntrypoint()
  void main() {
    group('$className', () async {
      NgTestBed testBed;
      TestFixture testFixture;

      setUp(() async {
        testBed = new NgTestBed<TestFixture>();
        testFixture = await testBed.create();
      });

      tearDown(disposeAnyRunningTest);

      test('fixme!', () async {
        expect(true, false);
      });
    });
  }

  @Component(
    selector: 'test-fixture',
    template: '<$selectorName></$selectorName>',
    directives: const [$className],
  )
  class TestFixture {}
  ''';
}

/// A configuration class for the template generator.
class Config {
  /// The value of the [preserveWhitespace] option in the @Component metadata.
  bool preserveWhitespace;

  /// The component's selector name.
  String name;
}
