// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionData _$VersionDataFromJson(Map<String, dynamic> json) {
  return VersionData(
    ArgumentsData.fromJson(json['arguments'] as Map<String, dynamic>),
    AssetsIndex.fromJson(json['assetsIndex'] as Map<String, dynamic>),
    json['assets'] as String,
    json['complianceLevel'] as int,
    CoreDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
    json['id'] as String,
    (json['libraries'] as List<dynamic>)
        .map((e) => Library.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$VersionDataToJson(VersionData instance) =>
    <String, dynamic>{
      'arguments': instance.arguments.toJson(),
      'assetsIndex': instance.assetsIndex.toJson(),
      'assets': instance.assets,
      'complianceLevel': instance.complianceLevel,
      'downloads': instance.downloads.toJson(),
      'id': instance.id,
      'libraries': instance.libraries.map((e) => e.toJson()).toList(),
    };
