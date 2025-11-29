// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_core/src/direct_run.dart';
import 'package:test_core/src/runner/reporter/json.dart';

import 'file_1_test.dart' as t1;
import 'file_2_test.dart' as t2;

void main() async {
  _HottieBinding.ensureInitialized();

  final success = await directRunTests(() {
    t1.main();
    t2.main();
  }, reporterFactory: (engine) => JsonReporter.watch(engine, stdout, isDebugRun: false));

  print('All tests completed, success: $success');
}

class _HottieBinding extends AutomatedTestWidgetsFlutterBinding {
  static final instance = _HottieBinding();

  static void ensureInitialized() {
    final _ = _HottieBinding.instance;
  }

  @override
  void scheduleWarmUpFrame() {
    if (!inTest) {
      return; // avoid assertion
    }
    super.scheduleWarmUpFrame();
  }
}
