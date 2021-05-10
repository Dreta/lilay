// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetObject _$AssetObjectFromJson(Map<String, dynamic> json) {
  return AssetObject(
    json['hash'] as String,
    json['size'] as int,
  );
}

Map<String, dynamic> _$AssetObjectToJson(AssetObject instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'size': instance.size,
    };
