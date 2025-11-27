import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';

import 'file_1_test.dart' as t1;
import 'file_2_test.dart' as t2;

// in VSCode, pressing F5 should run this
// can be run from terminal, but won't reload automatically
// flutter run test/runner.dart -d flutter-tester
void main() {
  runApp(
    OnReassemble(
      repeats: 1, // increase to test what happens with more spawns
      spawn: () {
        _spawn('_t1'.toNativeUtf8(), ''.toNativeUtf8());
        _spawn('_t2'.toNativeUtf8(), ''.toNativeUtf8());
      },
    ),
  );
}

@pragma("vm:entry-point")
void _t1() => t1.main();

@pragma("vm:entry-point")
void _t2() => t2.main();

/// BOILERPLATE BELOW

class OnReassemble extends StatefulWidget {
  final int repeats;
  final VoidCallback spawn;
  const OnReassemble({super.key, required this.spawn, this.repeats = 1});

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

  void _run() {
    for (int i = 0; i < widget.repeats; i++) {
      widget.spawn();
    }
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}

@Native<Void Function(Pointer<Utf8>, Pointer<Utf8>)>(symbol: 'Spawn')
external void _spawn(Pointer<Utf8> entrypoint, Pointer<Utf8> route);
