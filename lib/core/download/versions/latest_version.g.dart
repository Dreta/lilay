// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestVersion _$LatestVersionFromJson(Map<String, dynamic> json) {
  return LatestVersion(
    json['release'] as String,
    json['snapshot'] as String,
  );
}

Map<String, dynamic> _$LatestVersionToJson(LatestVersion instance) =>
    <String, dynamic>{
      'release': instance.release,
      'snapshot': instance.snapshot,
    };
