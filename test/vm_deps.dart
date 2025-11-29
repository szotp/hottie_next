// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'dart:isolate' as iso;

import 'package:vm_service/vm_service_io.dart';

Future<void> runTests(void Function() testMain) async {
  //await main();
  runZoned(testMain, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}));
}

Future<void> main() => printLibraries();

Future<void> printLibraries() async {
  // Get the VM service URI using dart:developer
  final serviceInfo = await Service.getInfo();
  final serverUri = serviceInfo.serverUri!;
  final wsUri = 'ws://${serverUri.authority}${serverUri.path}ws';

  final vmService = await vmServiceConnectUri(wsUri);

  // Get current isolate ID directly from dart:developer
  final isolateId = Service.getIsolateId(iso.Isolate.current);

  // Get detailed isolate info including libraries
  final isolate = await vmService.getIsolate(isolateId!);
  v

  final libraries = isolate.libraries!.where((x) => x.uri?.contains("hottie_next") ?? false).toList();

  print('$isolateId/libraries: ${libraries.map((x) => x.uri!.split("/").last).join(", ")}');

  vmService.get

  await vmService.dispose();
}
