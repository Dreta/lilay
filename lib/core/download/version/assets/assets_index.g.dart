// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsIndex _$AssetsIndexFromJson(Map<String, dynamic> json) {
  return AssetsIndex(
    json['id'] as String,
    json['sha1'] as String,
    json['size'] as int,
    json['totalSize'] as int,
    json['url'] as String,
  );
}

Map<String, dynamic> _$AssetsIndexToJson(AssetsIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sha1': instance.sha1,
      'size': instance.size,
      'totalSize': instance.totalSize,
      'url': instance.url,
    };
