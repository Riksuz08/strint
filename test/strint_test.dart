import 'package:flutter_test/flutter_test.dart';
import 'package:strint/strint.dart';

void main() {
  group('CreateModel', () {
    test('generates freezed class with Safe* annotations', () {
      final code = CreateModel('ReportModel', {
        'int?': 'id',
        'String?': 'dollar_rate',
      });
      expect(code, contains("class ReportModel with _\$ReportModel"));
      expect(code, contains("@SafeInt()"));
      expect(code, contains("@SafeString()"));
      expect(code, contains("int? id"));
      expect(code, contains("String? dollarRate"));
      expect(code, contains("@JsonKey(name: 'id')"));
      expect(code, contains("@JsonKey(name: 'dollar_rate')"));
      expect(code, contains("part 'report_model.freezed.dart'"));
      expect(code, contains("factory ReportModel.fromJson"));
    });
  });

  group('Safe converters', () {
    test('SafeString returns null for int', () {
      const c = SafeString();
      expect(c.fromJson(123), isNull);
      expect(c.fromJson('hello'), 'hello');
    });
    test('SafeInt returns int for int, null for string', () {
      const c = SafeInt();
      expect(c.fromJson(42), 42);
      expect(c.fromJson('wrong'), isNull);
    });
  });
}
