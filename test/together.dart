import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'file_1_test.dart' as t1;
import 'file_2_test.dart' as t2;

void main() {
  runApp(TestRunnerWidget());
}

class TestRunnerWidget extends StatefulWidget {
  const TestRunnerWidget({super.key});

  @override
  State<TestRunnerWidget> createState() => _TestRunnerWidgetState();
}

class _TestRunnerWidgetState extends State<TestRunnerWidget> {
  @override
  void initState() {
    spawn();
    super.initState();
  }

  @override
  void reassemble() {
    spawn();
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

@pragma("vm:entry-point")
void runTests() {
  runZoned(() {
    t1.main();
    t2.main();
  }, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}));
}

@Native<Void Function(Pointer<Utf8>, Pointer<Utf8>)>(symbol: 'Spawn')
external void _spawn(Pointer<Utf8> entrypoint, Pointer<Utf8> route);

void spawn({SendPort? port, String entrypoint = 'runTests', String route = '/'}) {
  assert(entrypoint != 'main' || route != '/', 'Spawn should not be used to spawn main with the default route name');
  if (port != null) {
    IsolateNameServer.registerPortWithName(port, route);
  }

  _spawn(entrypoint.toNativeUtf8(), route.toNativeUtf8());
}
