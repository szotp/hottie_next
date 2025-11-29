// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'file_1_test.dart' as f1;
import 'file_2_test.dart' as f2;
import 'hottie/dependency_finder.dart';
import 'hottie/runner.dart';
import 'hottie/watcher.dart';

// in VSCode, pressing F5 should run this
// can be run from terminal, but won't reload automatically
// flutter run test/runner.dart -d flutter-tester
Future<void> main() => runHottie(() async {});
