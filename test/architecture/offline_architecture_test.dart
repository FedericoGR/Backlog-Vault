import 'dart:io';

import 'package:test/test.dart';

void main() {
  late List<_SourceFile> sources;

  setUpAll(() {
    sources = _dartSources(Directory('lib'));
  });

  test('core never depends on features', () {
    final violations = <String>[];
    for (final source in sources.where(
      (item) => item.path.startsWith('lib/core/'),
    )) {
      for (final import in source.imports) {
        if (_resolvedPath(source, import).startsWith('lib/features/')) {
          violations.add('${source.path} -> $import');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation is isolated from persistence and infrastructure', () {
    const forbiddenPackages = [
      'dart:io',
      'package:drift/',
      'package:file_picker/',
      'package:http/',
      'package:flutter_secure_storage/',
    ];
    final violations = <String>[];
    for (final source in sources.where((item) => item.isPresentation)) {
      for (final import in source.imports) {
        final resolved = _resolvedPath(source, import);
        if (forbiddenPackages.any(import.startsWith) ||
            resolved.contains('/data/') ||
            resolved.startsWith('lib/core/database/')) {
          violations.add('${source.path} -> $import');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data never depends on presentation', () {
    final violations = <String>[];
    for (final source in sources.where((item) => item.isData)) {
      for (final import in source.imports) {
        if (_resolvedPath(source, import).contains('/presentation/')) {
          violations.add('${source.path} -> $import');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('non-visual feature dependencies are acyclic', () {
    final graph = <String, Set<String>>{};
    for (final source in sources.where(
      (item) => item.feature != null && !item.isPresentation,
    )) {
      final from = source.feature!;
      graph.putIfAbsent(from, () => <String>{});
      for (final import in source.imports) {
        final target = _featureFromPath(_resolvedPath(source, import));
        if (target != null && target != from) graph[from]!.add(target);
      }
    }
    final cycles = <String>[];
    final visited = <String>{};
    final active = <String>{};

    void visit(String node, List<String> path) {
      if (active.contains(node)) {
        final start = path.indexOf(node);
        cycles.add([...path.sublist(start), node].join(' -> '));
        return;
      }
      if (!visited.add(node)) return;
      active.add(node);
      for (final target in graph[node] ?? const <String>{}) {
        visit(target, [...path, node]);
      }
      active.remove(node);
    }

    for (final node in graph.keys) {
      visit(node, const []);
    }
    expect(cycles, isEmpty, reason: cycles.join('\n'));
  });

  test('removed Sync and legacy backup modules stay absent', () {
    const forbidden = [
      'features/sync/',
      'vaultsync',
      'vaultpair',
      'backup_restore',
      'encrypted_backup',
    ];
    final violations = <String>[];
    for (final source in sources) {
      final lowerPath = source.path.toLowerCase();
      for (final token in forbidden) {
        if (lowerPath.contains(token) ||
            source.imports.any(
              (value) => value.toLowerCase().contains(token),
            )) {
          violations.add('${source.path}: $token');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<_SourceFile> _dartSources(Directory root) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map(_SourceFile.read)
      .toList();
}

class _SourceFile {
  const _SourceFile({required this.path, required this.imports});

  factory _SourceFile.read(File file) {
    final path = file.path.replaceAll('\\', '/');
    final relative = path.substring(path.indexOf('lib/'));
    final imports =
        RegExp("^import ['\"]([^'\"]+)['\"]", multiLine: true)
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!)
            .toList();
    return _SourceFile(path: relative, imports: imports);
  }

  final String path;
  final List<String> imports;

  bool get isPresentation => path.contains('/presentation/');
  bool get isData => path.contains('/data/');
  String? get feature => _featureFromPath(path);
}

String _resolvedPath(_SourceFile source, String import) {
  if (import.startsWith('package:backlog_vault/')) {
    return 'lib/${import.substring('package:backlog_vault/'.length)}';
  }
  if (!import.startsWith('.')) return import;
  final base = Uri.parse('file:///${source.path}');
  return base.resolve(import).path.substring(1);
}

String? _featureFromPath(String path) {
  final match = RegExp(r'^lib/features/([^/]+)/').firstMatch(path);
  return match?.group(1);
}
