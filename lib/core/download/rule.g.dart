// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) {
  return Rule(
    _$enumDecode(_$RuleActionEnumMap, json['action']),
    json['features'] == null
        ? null
        : FeatureSet.fromJson(json['features'] as Map<String, dynamic>),
    json['os'] == null
        ? null
        : OSInfo.fromJson(json['os'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
      'action': _$RuleActionEnumMap[instance.action],
      'features': instance.features?.toJson(),
      'os': instance.os?.toJson(),
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

const _$RuleActionEnumMap = {
  RuleAction.allow: 'allow',
  RuleAction.disallow: 'disallow',
};

FeatureSet _$FeatureSetFromJson(Map<String, dynamic> json) {
  return FeatureSet(
    json['is_demo_user'] as bool?,
    json['has_custom_resolution'] as bool?,
  );
}

Map<String, dynamic> _$FeatureSetToJson(FeatureSet instance) =>
    <String, dynamic>{
      'is_demo_user': instance.isDemoUser,
      'has_custom_resolution': instance.hasCustomResolution,
    };

OSInfo _$OSInfoFromJson(Map<String, dynamic> json) {
  return OSInfo(
    json['name'] as String,
    json['arch'] as String?,
    json['version'] as String?,
  );
}

Map<String, dynamic> _$OSInfoToJson(OSInfo instance) => <String, dynamic>{
      'name': instance.name,
      'arch': instance.arch,
      'version': instance.version,
    };
