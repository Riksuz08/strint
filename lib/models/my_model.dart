import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:strint/safe_json.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    @JsonKey(name: 'id') @SafeInt() int? id,
    @JsonKey(name: 'name') @SafeString() String? name,
    @JsonKey(name: 'email') @SafeString() String? email,
    @JsonKey(name: 'isActive') @SafeBool() bool? isActive
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);
}
