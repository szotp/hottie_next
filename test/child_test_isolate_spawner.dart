import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:test_api/backend.dart'; // flutter_ignore: test_api_import

import '/Users/pawelszot/Development/hottie_next/test/some_other_test.dart' as t1;
import '/Users/pawelszot/Development/hottie_next/test/some_test.dart' as t2;

const List<String> packageTestArgs = <String>['--chain-stack-traces'];

const List<String> testPaths = <String>[
  'file:///Users/pawelszot/Development/hottie_next/test/some_other_test.dart',
  'file:///Users/pawelszot/Development/hottie_next/test/some_test.dart',
];

@Native<Void Function(Pointer<Utf8>, Pointer<Utf8>)>(symbol: 'Spawn')
external void _spawn(Pointer<Utf8> entrypoint, Pointer<Utf8> route);

void spawn({required SendPort port, String entrypoint = 'main', String route = '/'}) {
  assert(entrypoint != 'main' || route != '/', 'Spawn should not be used to spawn main with the default route name');
  IsolateNameServer.registerPortWithName(port, route);
  _spawn(entrypoint.toNativeUtf8(), route.toNativeUtf8());
}

/// Runs on a spawned isolate.
void createChannelAndConnect(String path, String name, Function testMain) {
  goldenFileComparator = LocalFileComparator(Uri.parse(path));
  autoUpdateGoldenFiles = false;
  final IsolateChannel<dynamic> channel = IsolateChannel<dynamic>.connectSend(IsolateNameServer.lookupPortByName(name)!);
  channel.pipe(RemoteListener.start(() => testMain));
}

@pragma('vm:entry-point')
void testMain() {
  final String route = PlatformDispatcher.instance.defaultRouteName;
  switch (route) {
    case '_Users_pawelszot_Development_hottie_next_test_some_other_test':
      createChannelAndConnect('/Users/pawelszot/Development/hottie_next/test/some_other_test.dart', route, t1.main);
    case '_Users_pawelszot_Development_hottie_next_test_some_test':
      createChannelAndConnect('/Users/pawelszot/Development/hottie_next/test/some_test.dart', route, t2.main);
  }
}

@pragma('vm:entry-point')
void main([dynamic sendPort]) {
  if (sendPort is SendPort) {
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic msg) {
      switch (msg as List<dynamic>) {
        case ['spawn', final SendPort port, final String entrypoint, final String route]:
          spawn(port: port, entrypoint: entrypoint, route: route);
        case ['close']:
          receivePort.close();
      }
    });

    sendPort.send(<Object>[receivePort.sendPort, packageTestArgs, testPaths]);
  }
}
