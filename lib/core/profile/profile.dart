/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Lilay is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Lilay.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  static const String DEFAULT_JVM_ARGUMENTS =
      '-Xmx4G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M';

  String name;

  /// [VersionData#id]
  String version;

  String? gameDirectory;
  int? resolutionWidth;
  int? resolutionHeight;

  String? javaExecutable;
  String jvmArguments;
  String gameArguments;

  Profile(
      String name,
      String version,
      String? gameDirectory,
      int? resolutionWidth,
      int? resolutionHeight,
      String? javaExecutable,
      String? jvmArguments,
      String? gameArguments)
      : this.name = name,
        this.version = version,
        this.gameDirectory = gameDirectory,
        this.resolutionWidth = resolutionWidth,
        this.resolutionHeight = resolutionHeight,
        this.javaExecutable = javaExecutable,
        this.jvmArguments = jvmArguments ?? DEFAULT_JVM_ARGUMENTS,
        this.gameArguments = gameArguments ?? '';

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
