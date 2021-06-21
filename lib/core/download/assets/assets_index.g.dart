// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsIndex _$AssetsIndexFromJson(Map<String, dynamic> json) {
  return AssetsIndex(
    (json['objects'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, Asset.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$AssetsIndexToJson(AssetsIndex instance) =>
    <String, dynamic>{
      'objects': instance.objects.map((k, e) => MapEntry(k, e.toJson())),
    };
