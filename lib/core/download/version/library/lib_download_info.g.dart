// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_download_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibDownloadInfo _$LibDownloadInfoFromJson(Map<String, dynamic> json) {
  return LibDownloadInfo(
    FriendlyDownload.fromJson(json['artifact'] as Map<String, dynamic>),
    ClassifiersDownload.fromJson(json['classifiers'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LibDownloadInfoToJson(LibDownloadInfo instance) =>
    <String, dynamic>{
      'artifact': instance.artifact.toJson(),
      'classifiers': instance.classifiers.toJson(),
    };
