// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) {
  return VersionInfo(
    json['id'] as String,
    _$enumDecode(_$VersionTypeEnumMap, json['type']),
    json['url'] as String,
    DateTime.parse(json['time'] as String),
    json['releaseTime'] == null
        ? null
        : DateTime.parse(json['releaseTime'] as String),
  );
}

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$VersionTypeEnumMap[instance.type],
      'url': instance.url,
      'time': instance.time.toIso8601String(),
      'releaseTime': instance.releaseTime?.toIso8601String(),
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
  VersionType.pending: 'pending',
  VersionType.old_beta: 'old_beta',
  VersionType.old_alpha: 'old_alpha',
};
