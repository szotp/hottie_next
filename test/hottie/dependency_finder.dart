// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate' as iso;

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

Future<void> runTests(void Function() testMain) async {
  //await main();
  runZoned(testMain, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}));
}

Future<void> main() => printLibraries();

Future<void> printLibraries() async {
  final finder = await DependencyFinder.connect();

  final sw = Stopwatch()..start();
  final libraries = await finder.findCurrentPackageLibraries();
  sw.stop();

  for (var entry in libraries.where((x) => x.isProbablyTest)) {
    final nested = entry.getNestedDependencies();
    print(nested.toString());
  }

  await finder.dispose();
}

class DependencyFinder {
  static Future<DependencyFinder> connect() async {
    final serviceInfo = await Service.getInfo();
    final serverUri = serviceInfo.serverUri!;
    final wsUri = 'ws://${serverUri.authority}${serverUri.path}ws';

    final vm = await vmServiceConnectUri(wsUri);
    return DependencyFinder(vm);
  }

  final VmService _vm;

  DependencyFinder(this._vm);

  Future<void> dispose() => _vm.dispose();

  final _isolateId = Service.getIsolateId(iso.Isolate.current)!;

  final _isCurrentPackage = IsCurrentPackage();

  Future<List<LibraryNode>> findCurrentPackageLibraries() async {
    final isolate = await _vm.getIsolate(_isolateId);
    final refs = isolate.libraries!.where(_isCurrentPackage.checkRef).toList();

    final futures = refs.map((e) => _vm.getObject(_isolateId, e.id!));
    final urisFuture = _vm.lookupResolvedPackageUris(_isolateId, refs.map((e) => e.uri!).toList());

    final results = await Future.wait(futures);
    final uris = await urisFuture;

    final mapped = results.cast<Library>().indexed.map((x) => LibraryNode(x.$2, uris.uris![x.$1]!)).toList();
    final nodesById = {for (final library in mapped) library.value.id!: library};

    for (final node in nodesById.values) {
      final dependencies = node.value.dependencies!.where(_isCurrentPackage.checkDependency).map((x) => nodesById[x.target!.id!]!);
      node.dependencies.addAll(dependencies);
    }

    return nodesById.values.toList();
  }
}

class LibraryNode {
  final Library value;
  final List<LibraryNode> dependencies = [];

  final String fileUri;

  LibraryNode(this.value, this.fileUri);

  bool get isProbablyTest => fileUri.endsWith('_test.dart');

  String get prettyJson {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value.json);
  }

  FileDependencies getNestedDependencies() {
    final visited = <String>{};
    void visit(LibraryNode node) {
      final uri = node.fileUri;

      if (!visited.add(uri)) {
        return;
      }

      node.dependencies.forEach(visit);
    }

    visit(this);
    return FileDependencies(fileUri, visited);
  }
}

class FileDependencies {
  final String uri;
  final Set<String> dependencies;

  FileDependencies(this.uri, this.dependencies);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('$uri:');

    for (final dep in dependencies) {
      buffer.writeln('  - $dep');
    }
    return buffer.toString();
  }
}

class IsCurrentPackage {
  final _currentDirectoryPath = Directory.current.path;
  late final String packagePrefix = 'package:${_extractPackageName()}';

  bool call(String? uri) {
    if (uri == null) return false;
    return uri.startsWith(packagePrefix) || uri.contains(_currentDirectoryPath);
  }

  bool checkRef(LibraryRef ref) => call(ref.uri);
  bool checkDependency(LibraryDependency dep) => call(dep.target!.uri!);

  String _extractPackageName() {
    final name = _currentDirectoryPath.split('/').last;
    return name;
  }
}
