import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("2/1", (tester) async {
    final text = Text('Hello');
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: text));
    final node = tester.getSemantics(find.byWidget(text));
    expect(node.label, equals('Hello'));
  });

  test("2/2", () async {
    expect(1, 1);
  });

  test("2/3", () async {
    expect(1, 1);
  });

  test("2/4", () async {
    expect(1, 1);
  });

  test("2/5", () async {
    expect(1, 1);
  });
}
