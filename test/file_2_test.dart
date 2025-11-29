import 'package:flutter_test/flutter_test.dart';
import 'package:hottie_next/calculator.dart';

import 'vm_deps.dart';

@pragma("vm:entry-point")
Future<void> test2() => runTests(main);

void main() {
  test("simple 1", () async {
    expect(1, 1);
  });

  test("simple 2", () async {
    expect(1, 1);
  });

  test("simple 3", () async {
    expect(1, 1);
  });

  test("simple 4", () async {
    expect(calculate(0, 1), 1);
  });
}
