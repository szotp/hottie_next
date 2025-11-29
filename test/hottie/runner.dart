// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../file_1_test.dart' as f1;
import '../file_2_test.dart' as f2;
import 'dependency_finder.dart';
import 'watcher.dart';

// in VSCode, pressing F5 should run this
// can be run from terminal, but won't reload automatically
// flutter run test/runner.dart -d flutter-tester
Future<void> runHottie(Future<void> Function() onReassemble) async {
  watchDartFiles().listen((file) {
    print(file); ////
  });

  runApp(
    OnReassemble(
      repeats: 1, // increase to test what happens with more spawns
      onReassemble: onReassemble,
    ),
  );
}

// @pragma("vm:entry-point")
// Future<void> _t1() async {
//   await vm_deps.main([]);
//   runZoned(t1.main, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}));
// }

// @pragma("vm:entry-point")
// Future<void> _t2() async {
//   await vm_deps.main([]);
//   runZoned(t2.main, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}));
// }

/// BOILERPLATE BELOW

class OnReassemble extends StatefulWidget {
  final int repeats;
  final AsyncCallback onReassemble;
  const OnReassemble({super.key, required this.onReassemble, this.repeats = 1});

  @override
  State<OnReassemble> createState() => _OnReassembleState();
}

class _OnReassembleState extends State<OnReassemble> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void reassemble() {
    super.reassemble();
    _run();
  }

  Future<void> _run() async {
    try {
      for (int i = 0; i < widget.repeats; i++) {
        await widget.onReassemble();
      }
    } catch (error, st) {
      print(error);
      print(st.toString().split("\n").take(5).join("\n"));
    }
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}
