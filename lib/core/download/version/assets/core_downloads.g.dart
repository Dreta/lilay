// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_downloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoreDownloads _$CoreDownloadsFromJson(Map<String, dynamic> json) {
  return CoreDownloads(
    json['client'] == null
        ? null
        : FriendlyDownload.fromJson(json['client'] as Map<String, dynamic>),
    json['client_mappings'] == null
        ? null
        : FriendlyDownload.fromJson(
            json['client_mappings'] as Map<String, dynamic>),
    json['server'] == null
        ? null
        : FriendlyDownload.fromJson(json['server'] as Map<String, dynamic>),
    json['server_mappings'] == null
        ? null
        : FriendlyDownload.fromJson(
            json['server_mappings'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CoreDownloadsToJson(CoreDownloads instance) =>
    <String, dynamic>{
      'client': instance.client?.toJson(),
      'client_mappings': instance.clientMappings?.toJson(),
      'server': instance.server?.toJson(),
      'server_mappings': instance.serverMappings?.toJson(),
    };
