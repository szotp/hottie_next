// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'vm_deps.dart';

@pragma("vm:entry-point")
Future<void> test1() => runTests(main);

void main() {
  test('empty', () {});
  test('simplest', () {
    expect(1, 1);
  });

  testWidgets('testWidgets', (tester) async {
    final text = Text('Hello');
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: text));
    final node = tester.getSemantics(find.byWidget(text));
    expect(node.label, equals('Hello'));
  });

  testWidgets("testWidgets fail", (tester) async {
    final text = Text('Hello');
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: text));
    final node = tester.getSemantics(find.byWidget(text));
    expect(node.label, equals('Hello world'));
  });

  test('async', () async {
    await Future.delayed(Duration(milliseconds: 100));
    expect(1, 1);
  });

  test(' async failing', () async {
    await Future.delayed(Duration(milliseconds: 100));
    throw TestFailure('fail!');
  });

  test(' async printing', () async {
    await Future.delayed(Duration(milliseconds: 100));
    print('printing a line');
  });
}
