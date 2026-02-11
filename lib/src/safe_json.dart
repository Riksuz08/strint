import 'package:json_annotation/json_annotation.dart';

/// ===============================
/// PRIMITIVES
/// ===============================

class SafeString implements JsonConverter<String?, dynamic> {
  const SafeString();

  @override
  String? fromJson(dynamic v) => v is String ? v : null;

  @override
  dynamic toJson(String? v) => v;
}

class SafeInt implements JsonConverter<int?, dynamic> {
  const SafeInt({this.acceptDouble = true, this.acceptNumericString = false});

  final bool acceptDouble; // 12.0 -> 12
  final bool acceptNumericString; // "12" -> 12

  @override
  int? fromJson(dynamic v) {
    if (v is int) return v;
    if (acceptDouble && v is double) return v.toInt();
    if (acceptNumericString && v is String) return int.tryParse(v);
    return null;
  }

  @override
  dynamic toJson(int? v) => v;
}

class SafeDouble implements JsonConverter<double?, dynamic> {
  const SafeDouble({this.acceptNumericString = false});

  final bool acceptNumericString; // "12.5" -> 12.5

  @override
  double? fromJson(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (acceptNumericString && v is String) return double.tryParse(v);
    return null;
  }

  @override
  dynamic toJson(double? v) => v;
}

class SafeBool implements JsonConverter<bool?, dynamic> {
  const SafeBool({this.acceptInt = false, this.acceptString = false});

  final bool acceptInt; // 0/1 -> false/true
  final bool acceptString; // "true"/"false" -> bool

  @override
  bool? fromJson(dynamic v) {
    if (v is bool) return v;
    if (acceptInt && v is int) return v != 0;
    if (acceptString && v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
    }
    return null;
  }

  @override
  dynamic toJson(bool? v) => v;
}

/// ISO8601 DateTime ("2026-01-29T12:34:56Z" or with offset)
class SafeDateTime implements JsonConverter<DateTime?, dynamic> {
  const SafeDateTime();

  @override
  DateTime? fromJson(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  @override
  dynamic toJson(DateTime? v) => v?.toIso8601String();
}

/// ===============================
/// ENUM (supports String name or int index)
/// ===============================

class SafeEnum<T extends Enum> implements JsonConverter<T?, dynamic> {
  const SafeEnum(
    this.values, {
    this.caseInsensitive = false,
  });

  final List<T> values;
  final bool caseInsensitive;

  @override
  T? fromJson(dynamic v) {
    if (v is String) {
      final s = caseInsensitive ? v.trim().toLowerCase() : v.trim();
      for (final e in values) {
        final n = caseInsensitive ? e.name.toLowerCase() : e.name;
        if (n == s) return e;
      }
      return null;
    }
    if (v is int) {
      if (v >= 0 && v < values.length) return values[v];
      return null;
    }
    return null;
  }

  @override
  dynamic toJson(T? v) => v?.name;
}

/// ===============================
/// MAP
/// ===============================

class SafeMap implements JsonConverter<Map<String, dynamic>?, dynamic> {
  const SafeMap();

  @override
  Map<String, dynamic>? fromJson(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return null;
  }

  @override
  dynamic toJson(Map<String, dynamic>? v) => v;
}

/// ===============================
/// OBJECT (Model)
/// ===============================

class SafeObject<T> implements JsonConverter<T?, dynamic> {
  const SafeObject(this.factory);

  final T Function(Map<String, dynamic>) factory;

  @override
  T? fromJson(dynamic v) {
    if (v is Map<String, dynamic>) return factory(v);
    if (v is Map) {
      final map = v.map((k, val) => MapEntry(k.toString(), val));
      return factory(Map<String, dynamic>.from(map));
    }
    return null;
  }

  @override
  dynamic toJson(T? v) => v;
}

/// ===============================
/// LIST of primitive
/// ===============================

class SafePrimitiveList<T> implements JsonConverter<List<T>?, dynamic> {
  const SafePrimitiveList();

  @override
  List<T>? fromJson(dynamic v) {
    if (v is! List) return null;
    return v.whereType<T>().toList();
  }

  @override
  dynamic toJson(List<T>? v) => v;
}

/// LIST of objects (models)
class SafeObjectList<T> implements JsonConverter<List<T>?, dynamic> {
  const SafeObjectList(this.factory);

  final T Function(Map<String, dynamic>) factory;

  @override
  List<T>? fromJson(dynamic v) {
    if (v is! List) return null;

    final result = <T>[];
    for (final item in v) {
      if (item is Map<String, dynamic>) {
        result.add(factory(item));
      } else if (item is Map) {
        final map = item.map((k, val) => MapEntry(k.toString(), val));
        result.add(factory(Map<String, dynamic>.from(map)));
      }
    }
    return result;
  }

  @override
  dynamic toJson(List<T>? v) => v;
}
