// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendly_download.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendlyDownload _$FriendlyDownloadFromJson(Map<String, dynamic> json) {
  return FriendlyDownload(
    json['path'] as String?,
    json['sha1'] as String,
    json['size'] as int,
    json['url'] as String,
  );
}

Map<String, dynamic> _$FriendlyDownloadToJson(FriendlyDownload instance) =>
    <String, dynamic>{
      'path': instance.path,
      'sha1': instance.sha1,
      'size': instance.size,
      'url': instance.url,
    };
