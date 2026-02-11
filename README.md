# strint

Safe JSON models for Flutter — avoid UI crashes when the backend sends wrong types (e.g. `int` instead of `String?`). Generates freezed models with **Safe\*** converters so mismatched types become `null` instead of throwing.

## Problem

You expect `String? dollarRate` from the API but sometimes get `int`. Standard `fromJson` throws and the app crashes.

## Solution

Define your model once (YAML or `CreateModel`), generate a freezed class that uses **SafeString**, **SafeInt**, etc. Wrong types are converted to `null` instead of crashing.

## Usage

### 1. Add dependency

In your app’s `pubspec.yaml`:

```yaml
dependencies:
  strint: <your path or version>
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
```

### 2. Create a model file (one command flow)

Create a new Dart file, e.g. `lib/models/my_model.dart`, with a single **CreateModel** call:

```dart
CreateModel('MyModel', {'int?': 'id', 'String?': 'name'});
```

Then from your project root run:

```bash
dart run strint:generate lib/models
```

This will:

1. Find all `.dart` files in `lib/models` that contain `CreateModel(...)`
2. Replace each file with the full freezed class (with Safe\* annotations)
3. Run **build_runner** to generate `.freezed.dart` and `.g.dart`

So one command both generates the model and runs the freezed generator.

### 3. Alternative: YAML config

Create `strint_models.yaml` in your project root:

```yaml
ReportModel:
  id: int?
  dollar_rate: String?
```

Then run:

```bash
dart run strint:generate
```

This creates `lib/models/report_model.dart` (and others). Run build_runner yourself:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use `dart run strint:generate strint_models.yaml lib/models --build-runner` to also run build_runner.

### 4. Or generate from code

```dart
import 'package:strint/strint.dart';

void main() {
  final code = CreateModel('ReportModel', {
    'int?': 'id',
    'String?': 'dollar_rate',
  });
  File('lib/models/report_model.dart').writeAsStringSync(code);
}
```

Then run build_runner as above.

### Supported types

- `int?`, `String?`, `double?`, `bool?`, `DateTime?`
- `Map?` / `Map<String, dynamic>?`
- `List<int>?`, `List<String>?`, `List<double>?`, `List<bool>?`
- Nested models: `ReportModel?` → `SafeObject(ReportModel.fromJson)`

## Generated example

From `ReportModel` with `id: int?` and `dollar_rate: String?` you get:

```dart
@freezed
class ReportModel with _$ReportModel {
  const factory ReportModel({
    @JsonKey(name: 'id') @SafeInt() int? id,
    @JsonKey(name: 'dollar_rate') @SafeString() String? dollarRate,
  }) = _$ReportModel;

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);
}
```

When the API sends `"dollar_rate": 42`, `SafeString.fromJson` returns `null` and the UI stays safe.

## License

See LICENSE.
