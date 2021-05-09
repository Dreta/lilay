// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'natives_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativesMapping _$NativesMappingFromJson(Map<String, dynamic> json) {
  return NativesMapping(
    json['windows'] as String?,
    json['osx'] as String?,
    json['linux'] as String?,
  );
}

Map<String, dynamic> _$NativesMappingToJson(NativesMapping instance) =>
    <String, dynamic>{
      'windows': instance.windows,
      'osx': instance.osx,
      'linux': instance.linux,
    };
