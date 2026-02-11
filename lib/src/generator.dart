/// Generates freezed + json_serializable Dart code from model name and field spec.
///
/// [fields]: map from JSON key to type (e.g. {'id': 'int?', 'dollar_rate': 'String?'}).
/// Using jsonKey -> type ensures multiple fields with the same type are all generated.
library;

/// Converts snake_case to camelCase.
String snakeToCamel(String s) {
  final parts = s.split('_');
  if (parts.length == 1) return s;
  return parts.first.toLowerCase() +
      parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase()).join();
}

/// Resolves Dart type and Safe converter annotation for a type string.
/// Returns (dartType, converterName) e.g. ("int?", "SafeInt").
(String dartType, String converter) resolveType(String typeKey) {
  final t = typeKey.trim();
  switch (t) {
    case 'int?':
    case 'int':
      return ('int?', 'SafeInt');
    case 'String?':
    case 'String':
      return ('String?', 'SafeString');
    case 'double?':
    case 'double':
      return ('double?', 'SafeDouble');
    case 'bool?':
    case 'bool':
      return ('bool?', 'SafeBool');
    case 'DateTime?':
    case 'DateTime':
      return ('DateTime?', 'SafeDateTime');
    case 'Map<String, dynamic>?':
    case 'Map?':
    case 'Map':
      return ('Map<String, dynamic>?', 'SafeMap');
    case 'List<int>?':
      return ('List<int>?', 'SafePrimitiveList<int>');
    case 'List<String>?':
      return ('List<String>?', 'SafePrimitiveList<String>');
    case 'List<double>?':
      return ('List<double>?', 'SafePrimitiveList<double>');
    case 'List<bool>?':
      return ('List<bool>?', 'SafePrimitiveList<bool>');
    default:
      // Nested model: e.g. "ReportModel?" -> SafeObject(ReportModel.fromJson)
      if (t.endsWith('?') && t.length > 1) {
        final inner = t.substring(0, t.length - 1);
        return ('$inner?', 'SafeObject($inner.fromJson)');
      }
      return (t, 'SafeObject($t.fromJson)');
  }
}

/// Generates the Dart source for a single freezed model.
String generateModel({
  required String modelName,
  required Map<String, String> fields,
  String safeJsonImport = "package:strint/safe_json.dart",
  String freezedImport = "package:freezed_annotation/freezed_annotation.dart",
  String jsonKeyImport = "package:json_annotation/json_annotation.dart",
}) {
  final buffer = StringBuffer();

  buffer.writeln("import '$freezedImport';");
  buffer.writeln("import '$jsonKeyImport';");
  buffer.writeln("import '$safeJsonImport';");
  buffer.writeln();
  final snakeFile = snakeCaseFileName(modelName);
  buffer.writeln("part '$snakeFile.freezed.dart';");
  buffer.writeln("part '$snakeFile.g.dart';");
  buffer.writeln();

  buffer.writeln('@freezed');
  buffer.writeln('class $modelName with _\$$modelName {');
  buffer.writeln('  const factory $modelName({');

  final entries = fields.entries.toList();
  for (var i = 0; i < entries.length; i++) {
    final jsonKey = entries[i].key;
    final typeKey = entries[i].value;
    final (dartType, converter) = resolveType(typeKey);
    final fieldName = snakeToCamel(jsonKey);
    final comma = i < entries.length - 1 ? ',' : '';
    buffer.writeln("    @JsonKey(name: '$jsonKey') @$converter() $dartType $fieldName$comma");
  }

  buffer.writeln('  }) = _$modelName;');
  buffer.writeln();
  buffer.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) =>');
  buffer.writeln('      _\$${modelName}FromJson(json);');
  buffer.writeln('}');

  return buffer.toString();
}

String snakeCaseFileName(String modelName) {
  return modelName.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (m) => '_${m.group(1)!.toLowerCase()}',
  ).replaceFirst(RegExp(r'^_'), '');
}
