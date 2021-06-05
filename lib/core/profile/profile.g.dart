// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['name'] as String,
    json['version'] as String,
    json['gameDirectory'] as String?,
    json['resolutionWidth'] as int?,
    json['resolutionHeight'] as int?,
    json['javaExecutable'] as String?,
    json['jvmArguments'] as String?,
    json['gameArguments'] as String?,
    json['selected'] as bool?,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'gameDirectory': instance.gameDirectory,
      'resolutionWidth': instance.resolutionWidth,
      'resolutionHeight': instance.resolutionHeight,
      'javaExecutable': instance.javaExecutable,
      'jvmArguments': instance.jvmArguments,
      'gameArguments': instance.gameArguments,
      'selected': instance.selected,
    };
