import 'dart:async';
import 'dart:ffi';
import 'dart:io' show exit, exitCode; // flutter_ignore: dart_io_import
import 'dart:isolate';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test_core/src/executable.dart' as test; // ignore: implementation_imports
import 'package:test_core/src/platform.dart'; // ignore: implementation_imports

@Native<Handle Function(Pointer<Utf8>)>(symbol: 'LoadLibraryFromKernel')
external Object _loadLibraryFromKernel(Pointer<Utf8> path);

@Native<Handle Function(Pointer<Utf8>, Pointer<Utf8>)>(symbol: 'LookupEntryPoint')
external Object _lookupEntryPoint(Pointer<Utf8> library, Pointer<Utf8> name);

late final List<String> packageTestArgs;
late final List<String> testPaths;

/// Runs on the main isolate.
Future<void> registerPluginAndRun() {
  final SpawnPlugin platform = SpawnPlugin();
  registerPlatformPlugin(
    <Runtime>[Runtime.vm],
    () {
      return platform;
    },
  );
  return test.main(<String>[...packageTestArgs, '--', ...testPaths]);
}

late final Isolate rootTestIsolate;
late final SendPort commandPort;
bool readyToRun = false;
final Completer<void> readyToRunSignal = Completer<void>();

Future<void> spawn({
  required SendPort port,
  String entrypoint = 'main',
  String route = '/',
}) async {
  if (!readyToRun) {
    await readyToRunSignal.future;
  }

  commandPort.send(<Object>['spawn', port, entrypoint, route]);
}

@pragma('vm:entry-point')
void main() async {
  final String route = PlatformDispatcher.instance.defaultRouteName;

  if (route == '/') {
    final ReceivePort port = ReceivePort();

    port.listen((dynamic message) {
      final [SendPort sendPort, List<String> args, List<String> paths] = message as List<dynamic>;

      commandPort = sendPort;
      packageTestArgs = args;
      testPaths = paths;
      readyToRun = true;
      readyToRunSignal.complete();
    });

    rootTestIsolate = await Isolate.spawn(
      _loadLibraryFromKernel(
          r'/Users/pawelszot/Development/hottie_next/build/isolate_spawning_tester/child_test_isolate_spawner.dill'
              .toNativeUtf8()) as void Function(SendPort),
      port.sendPort,
    );

    await readyToRunSignal.future;
    port.close(); // Not expecting anything else.
    await registerPluginAndRun();
    // The [test.main] call in [registerPluginAndRun] sets dart:io's [exitCode]
    // global.
    exit(exitCode);
  } else {
    (_lookupEntryPoint(
        r'file:///Users/pawelszot/Development/hottie_next/build/isolate_spawning_tester/child_test_isolate_spawner.dart'
            .toNativeUtf8(),
        'testMain'.toNativeUtf8()) as void Function())();
  }
}

String pathToImport(String path) {
  assert(path.endsWith('.dart'));
  return path
      .replaceRange(path.length - '.dart'.length, null, '')
      .replaceAll('.', '_')
      .replaceAll(':', '_')
      .replaceAll('/', '_')
      .replaceAll(r'\', '_');
}

class SpawnPlugin extends PlatformPlugin {
  SpawnPlugin();

  final Map<String, IsolateChannel<dynamic>> _channels = <String, IsolateChannel<dynamic>>{};

  Future<void> launchIsolate(String path) async {
    final String name = pathToImport(path);
    final ReceivePort port = ReceivePort();
    _channels[name] = IsolateChannel<dynamic>.connectReceive(port);
    await spawn(port: port.sendPort, route: name);
  }

  @override
  Future<void> close() async {
    commandPort.send(<String>['close']);
  }
  @override
  Future<RunnerSuite> load(
    String path,
    SuitePlatform platform,
    SuiteConfiguration suiteConfig,
    Object message,
  ) async {
    final String correctedPath = path;
    await launchIsolate(correctedPath);

    final StreamChannel<dynamic> channel = _channels[pathToImport(correctedPath)]!;
    final RunnerSuiteController controller = deserializeSuite(correctedPath, platform,
        suiteConfig, const PluginEnvironment(), channel, message);
    return controller.suite;
  }
}
