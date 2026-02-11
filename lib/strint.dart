/// Safe JSON models — avoid UI crashes when the backend sends wrong types.
///
/// Use [CreateModel] spec + code generation to get freezed models with Safe*
/// converters. When the API returns e.g. `int` for a field you expected as
/// `String?`, the converter returns `null` instead of throwing.
///
/// ## 1. Define models (YAML)
///
/// Create `strint_models.yaml` in your project:
///
/// ```yaml
/// ReportModel:
///   id: int?
///   dollar_rate: String?
/// ```
///
/// ## 2. Generate Dart code
///
/// ```bash
/// dart run strint:generate
/// ```
///
/// Then run build_runner for freezed:
///
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
library strint;

import 'src/generator.dart' show generateModel;

export 'src/safe_json.dart';
export 'src/generator.dart';

/// Known type names (with or without ?). Used to detect type->key map format.
const _typeNames = {
  'int', 'int?', 'String', 'String?', 'double', 'double?', 'bool', 'bool?',
  'DateTime', 'DateTime?', 'Map', 'Map?', 'Map<String, dynamic>?',
  'List<int>?', 'List<String>?', 'List<double>?', 'List<bool>?',
};

bool _looksLikeType(String key) =>
    key.endsWith('?') && key.length > 1 || _typeNames.contains(key);

/// Generates the freezed + Safe* model Dart source.
///
/// [fields] can be either:
/// - json key -> type: `{'id': 'int?', 'dollar_rate': 'String?'}`
/// - type -> json key: `{'int?': 'id', 'String?': 'dollar_rate'}`
/// (auto-detected so both work.)
///
/// Example:
/// ```dart
/// final code = CreateModel('ReportModel', {'int?': 'id', 'String?': 'dollar_rate'});
/// File('lib/models/report_model.dart').writeAsStringSync(code);
/// ```
/// Then run: `dart run build_runner build --delete-conflicting-outputs`
String CreateModel(String modelName, Map<String, String> fields) {
  final keyToType = fields.keys.every(_looksLikeType)
      ? {for (final e in fields.entries) e.value: e.key}
      : Map<String, String>.from(fields);
  return generateModel(modelName: modelName, fields: keyToType);
}
