// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionData _$VersionDataFromJson(Map<String, dynamic> json) {
  return VersionData(
    json['arguments'] == null
        ? null
        : ArgumentsData.fromJson(json['arguments'] as Map<String, dynamic>),
    json['assetIndex'] == null
        ? null
        : AssetsIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
    json['assets'] as String,
    json['complianceLevel'] as int,
    CoreDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
    json['id'] as String,
    (json['libraries'] as List<dynamic>)
        .map((e) => Library.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['mainClass'] as String,
    json['minecraftArguments'] as String?,
    DateTime.parse(json['releaseTime'] as String),
    DateTime.parse(json['time'] as String),
    _$enumDecode(_$VersionTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$VersionDataToJson(VersionData instance) =>
    <String, dynamic>{
      'arguments': instance.arguments?.toJson(),
      'assetIndex': instance.assetIndex?.toJson(),
      'assets': instance.assets,
      'complianceLevel': instance.complianceLevel,
      'downloads': instance.downloads.toJson(),
      'id': instance.id,
      'libraries': instance.libraries.map((e) => e.toJson()).toList(),
      'mainClass': instance.mainClass,
      'minecraftArguments': instance.minecraftArguments,
      'releaseTime': instance.releaseTime.toIso8601String(),
      'time': instance.time.toIso8601String(),
      'type': _$VersionTypeEnumMap[instance.type],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$VersionTypeEnumMap = {
  VersionType.snapshot: 'snapshot',
  VersionType.release: 'release',
  VersionType.old_beta: 'old_beta',
  VersionType.old_alpha: 'old_alpha',
};
