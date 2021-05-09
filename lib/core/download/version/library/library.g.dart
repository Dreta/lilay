// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Library _$LibraryFromJson(Map<String, dynamic> json) {
  return Library(
    LibDownloadInfo.fromJson(json['downloads'] as Map<String, dynamic>),
    json['name'] as String,
    json['natives'] == null
        ? null
        : NativesMapping.fromJson(json['natives'] as Map<String, dynamic>),
    (json['rules'] as List<dynamic>?)
        ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$LibraryToJson(Library instance) => <String, dynamic>{
      'downloads': instance.downloads.toJson(),
      'name': instance.name,
      'natives': instance.natives?.toJson(),
      'rules': instance.rules.map((e) => e.toJson()).toList(),
    };
