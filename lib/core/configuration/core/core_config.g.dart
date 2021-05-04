// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoreConfig _$CoreConfigFromJson(Map<String, dynamic> json) {
  return CoreConfig(
    json['workingDirectory'] as String?,
    _$enumDecodeNullable(_$BackgroundTypeEnumMap, json['backgroundType']),
    json['backgroundImage'] as String?,
    json['preferredLoginType'] as String?,
    json['accent'] as int?,
    _$enumDecodeNullable(_$DarkModeTypeEnumMap, json['darkMode']),
    json['downloadSource'] as String?,
  );
}

Map<String, dynamic> _$CoreConfigToJson(CoreConfig instance) =>
    <String, dynamic>{
      'workingDirectory': instance.workingDirectory,
      'backgroundType': _$BackgroundTypeEnumMap[instance.backgroundType],
      'backgroundImage': instance.backgroundImage,
      'preferredLoginType': instance.preferredLoginType,
      'accent': instance.accent,
      'darkMode': _$DarkModeTypeEnumMap[instance.darkMode],
      'downloadSource': instance.downloadSource,
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

const _$BackgroundTypeEnumMap = {
  BackgroundType.asset: 'asset',
  BackgroundType.custom: 'custom',
};

const _$DarkModeTypeEnumMap = {
  DarkModeType.light: 'light',
  DarkModeType.dark: 'dark',
  DarkModeType.system: 'system',
};
