import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/utils.dart';

part 'core_config.g.dart';

@JsonSerializable()
class CoreConfig {
  String workingDirectory;

  CoreConfig(String? workingDirectory)
      : this.workingDirectory = workingDirectory ?? getDefaultMinecraft();

  factory CoreConfig.fromJson(Map<String, dynamic> json) =>
      _$CoreConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CoreConfigToJson(this);
}
