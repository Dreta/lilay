// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionManifest _$VersionManifestFromJson(Map<String, dynamic> json) {
  return VersionManifest(
    LatestVersion.fromJson(json['latest'] as Map<String, dynamic>),
    (json['versions'] as List<dynamic>)
        .map((e) => VersionInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$VersionManifestToJson(VersionManifest instance) =>
    <String, dynamic>{
      'latest': instance.latest.toJson(),
      'versions': instance.versions.map((e) => e.toJson()).toList(),
    };
