/// Parses CreateModel('ModelName', {'type?': 'json_key', ...}) from Dart source.
library;

/// Result of parsing a single CreateModel call.
class CreateModelSpec {
  CreateModelSpec(this.modelName, this.fields);
  final String modelName;
  /// json key -> type (e.g. {'id': 'int?', 'name': 'String?'}) so duplicate types don't overwrite.
  final Map<String, String> fields;
}

/// Extracts CreateModel('Name', { ... }) from [source].
/// Returns null if not found or parse fails.
CreateModelSpec? parseCreateModelFromSource(String source) {
  const pattern = r"CreateModel\s*\(\s*'([^']+)'\s*,\s*";
  final startMatch = RegExp(pattern).firstMatch(source);
  if (startMatch == null) return null;

  final modelName = startMatch.group(1)!.trim();
  if (modelName.isEmpty) return null;

  final mapStart = startMatch.end;
  final braceStart = source.indexOf('{', mapStart);
  if (braceStart == -1) return null;

  int depth = 1;
  int i = braceStart + 1;
  while (i < source.length && depth > 0) {
    final c = source[i];
    if (c == '{') depth++;
    if (c == '}') depth--;
    i++;
  }
  if (depth != 0) return null;

  final mapContent = source.substring(braceStart + 1, i - 1);

  // Parse map entries: 'type' : 'json_key' — store as jsonKey -> type so duplicate types (e.g. two String?) don't overwrite
  final fields = <String, String>{};
  final entryPattern = RegExp(r"""['"]([^'"]+)['"]\s*:\s*['"]([^'"]+)['"]""");
  for (final m in entryPattern.allMatches(mapContent)) {
    final typeKey = m.group(1)!.trim();
    final jsonKey = m.group(2)!.trim();
    if (typeKey.isNotEmpty && jsonKey.isNotEmpty) {
      fields[jsonKey] = typeKey;
    }
  }

  if (fields.isEmpty) return null;
  return CreateModelSpec(modelName, fields);
}
