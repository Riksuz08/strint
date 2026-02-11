// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MyModelImpl _$$MyModelImplFromJson(Map<String, dynamic> json) =>
    _$MyModelImpl(
      id: const SafeInt().fromJson(json['id']),
      name: const SafeString().fromJson(json['name']),
      email: const SafeString().fromJson(json['email']),
      isActive: const SafeBool().fromJson(json['isActive']),
    );

Map<String, dynamic> _$$MyModelImplToJson(_$MyModelImpl instance) =>
    <String, dynamic>{
      'id': const SafeInt().toJson(instance.id),
      'name': const SafeString().toJson(instance.name),
      'email': const SafeString().toJson(instance.email),
      'isActive': const SafeBool().toJson(instance.isActive),
    };
