// ignore_for_file: avoid_print
import 'dart:io';

import 'package:strint/strint.dart';
import 'package:strint/src/parse_create_model.dart';
import 'package:yaml/yaml.dart';

/// Config file name (in current directory).
const defaultConfigPath = 'strint_models.yaml';

/// Default output directory relative to current directory.
const defaultOutputDir = 'lib/models';

void main(List<String> arguments) {
  final rest = arguments.where((a) => a != '--build-runner').toList();
  final runBuildRunner = arguments.contains('--build-runner');
  final configPath = rest.isNotEmpty ? rest[0] : defaultConfigPath;
  final outputDir = rest.length > 1 ? rest[1] : defaultOutputDir;

  final configFile = File(configPath);

  // Mode 1: First argument is a directory → scan .dart files for CreateModel, generate & overwrite, then run build_runner
  if (rest.isNotEmpty) {
    final path = rest[0];
    final dir = Directory(path);
    if (dir.existsSync()) {
      runFromDartDir(path, runBuildRunner);
      return;
    }
  }

  // Mode 2: YAML config
  if (!configFile.existsSync()) {
    print("Config not found: $configPath");
    print("");
    print("Option A — YAML: create $defaultConfigPath with model definitions.");
    print("Option B — Dart: create lib/models/my_model.dart with:");
    print("  CreateModel('MyModel', {'int?': 'id', 'String?': 'name'});");
    print("  Then run: dart run strint:generate lib/models");
    print("");
    exit(1);
  }

  if (configFile.path.endsWith('.yaml') || configFile.path.endsWith('.yml')) {
    runFromYaml(configFile, outputDir);
    if (runBuildRunner) runBuildRunnerCmd();
    return;
  }

  print("Unknown config: $configPath");
  exit(1);
}

/// Scan directory for .dart files containing CreateModel, generate and overwrite.
void runFromDartDir(String dirPath, bool runBuildRunner) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    print("Directory not found: $dirPath");
    exit(1);
  }

  final dartFiles = dir
      .listSync(recursive: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  var count = 0;
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final spec = parseCreateModelFromSource(content);
    if (spec == null) continue;

    final code = generateModel(modelName: spec.modelName, fields: spec.fields);
    file.writeAsStringSync(code);
    print("Generated: ${file.path} (${spec.modelName})");
    count++;
  }

  if (count == 0) {
    print("No CreateModel(...) found in .dart files under $dirPath");
    print("");
    print("Example my_model.dart:");
    print("  CreateModel('MyModel', {'int?': 'id', 'String?': 'name'});");
    exit(1);
  }

  print("");
  runBuildRunnerCmd();
}

void runFromYaml(File configFile, String outputDir) {
  final content = configFile.readAsStringSync();
  dynamic yaml;
  try {
    yaml = loadYaml(content);
  } catch (e) {
    print("Invalid YAML: $e");
    exit(1);
  }

  if (yaml is! YamlMap) {
    print("YAML root must be a map (model names -> fields).");
    exit(1);
  }

  final models = yaml;
  final outDir = Directory(outputDir);
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  for (final entry in models.entries) {
    final modelName = entry.key.toString();
    final fieldsNode = entry.value;
    if (fieldsNode is! YamlMap) {
      print("Skip $modelName: fields must be a map.");
      continue;
    }
    final keyToType = <String, String>{};
    for (final e in fieldsNode.entries) {
      keyToType[e.key.toString()] = e.value.toString();
    }

    final code = generateModel(modelName: modelName, fields: keyToType);
    final snakeFile = snakeCaseFileName(modelName);
    final outFile = File('$outputDir/$snakeFile.dart');
    outFile.writeAsStringSync(code);
    print("Generated: ${outFile.path}");
  }

  print("");
  print("Run build_runner to generate .freezed.dart and .g.dart:");
  print("  dart run build_runner build --delete-conflicting-outputs");
}

void runBuildRunnerCmd() {
  print("Running build_runner...");
  final result = Process.runSync(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );
  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    exit(result.exitCode);
  }
  print(result.stdout);
  print("Done.");
}
