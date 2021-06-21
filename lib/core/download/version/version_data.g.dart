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
    json['assets'] as String?,
    json['complianceLevel'] as int?,
    json['downloads'] == null
        ? null
        : CoreDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
    json['id'] as String,
    json['inheritsFrom'] as String?,
    (json['libraries'] as List<dynamic>?)
        ?.map((e) => Library.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['mainClass'] as String?,
    json['minecraftArguments'] as String?,
    json['releaseTime'] == null
        ? null
        : DateTime.parse(json['releaseTime'] as String),
    json['time'] == null ? null : DateTime.parse(json['time'] as String),
    _$enumDecodeNullable(_$VersionTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$VersionDataToJson(VersionData instance) =>
    <String, dynamic>{
      'arguments': instance.selfArguments?.toJson(),
      'assetIndex': instance.selfAssetIndex?.toJson(),
      'assets': instance.selfAssets,
      'complianceLevel': instance.selfComplianceLevel,
      'downloads': instance.selfDownloads?.toJson(),
      'id': instance.selfID,
      'inheritsFrom': instance.selfInheritsFrom,
      'libraries': instance.selfLibraries?.map((e) => e.toJson()).toList(),
      'mainClass': instance.selfMainClass,
      'minecraftArguments': instance.selfMinecraftArguments,
      'releaseTime': instance.selfReleaseTime?.toIso8601String(),
      'time': instance.selfTime?.toIso8601String(),
      'type': _$VersionTypeEnumMap[instance.selfType],
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$VersionTypeEnumMap = {
  VersionType.snapshot: 'snapshot',
  VersionType.release: 'release',
  VersionType.old_beta: 'old_beta',
  VersionType.old_alpha: 'old_alpha',
};
