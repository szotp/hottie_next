import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hottie_next/calculator.dart';

void main() {
  test('1/1', () {
    expect(1, 1);
  });

  testWidgets("1/2", (tester) async {
    final text = Text('Hello');
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: text));
    final node = tester.getSemantics(find.byWidget(text));
    expect(node.label, equals('Hello'));
  });

  test('1/3', () {
    expect(calculate(1, 1), 2);
  });
}
