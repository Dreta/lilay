// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classifiers_download.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassifiersDownload _$ClassifiersDownloadFromJson(Map<String, dynamic> json) {
  return ClassifiersDownload(
    json['javadoc'] == null
        ? null
        : FriendlyDownload.fromJson(json['javadoc'] as Map<String, dynamic>),
    json['natives-linux'] == null
        ? null
        : FriendlyDownload.fromJson(
            json['natives-linux'] as Map<String, dynamic>),
    json['natives-macos'] == null
        ? null
        : FriendlyDownload.fromJson(
            json['natives-macos'] as Map<String, dynamic>),
    json['natives-windows'] == null
        ? null
        : FriendlyDownload.fromJson(
            json['natives-windows'] as Map<String, dynamic>),
    json['sources'] == null
        ? null
        : FriendlyDownload.fromJson(json['sources'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ClassifiersDownloadToJson(
        ClassifiersDownload instance) =>
    <String, dynamic>{
      'javadoc': instance.javadocs?.toJson(),
      'natives-linux': instance.nativesLinux?.toJson(),
      'natives-macos': instance.nativesMacOS?.toJson(),
      'natives-windows': instance.nativesWindows?.toJson(),
      'sources': instance.sources?.toJson(),
    };
