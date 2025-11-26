import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hottie_next/main.dart';

void main() {
  tearDown(() {
    dlog('file_2: tearDown');
  });

  tearDownAll(() {
    dlog('file_2: tearDownAll');
  });

  testWidgets("file_2/1", (tester) async {
    final text = Text('Hello');
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: text));
    final node = tester.getSemantics(find.byWidget(text));
    expect(node.label, equals('Hello'));
  });

  test("file_2/2", () async {
    expect(1, 2);
  });
}
