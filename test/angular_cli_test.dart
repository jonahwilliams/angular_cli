// Copyright (c) 2017, Jonah Williams. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular_cli/angular_cli.dart';
import 'package:test/test.dart';

void main() {
  test('kebabToCamel converts a custom element name to a class name', () {
    expect(kebabToCamel('my-component'), 'myComponentComponent');
  });

  test('kebabToSnake converts a custom element name to a file name', () {
    expect(kebabToSnake('my-component'), 'my_component');
  });
}
