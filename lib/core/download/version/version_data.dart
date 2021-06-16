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
import 'package:lilay/core/download/version/assets/assets_index.dart';
import 'package:lilay/core/download/version/assets/core_downloads.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/versions/version_info.dart';

import 'arguments/arguments_data.dart';

part 'version_data.g.dart';

@JsonSerializable(explicitToJson: true)
class VersionData {
  // TODO support inherits from
  ArgumentsData? arguments;
  AssetsIndex? assetIndex;
  String assets;
  int complianceLevel;
  CoreDownloads downloads;
  String id;
  List<Library> libraries;

  // TODO support logging
  String mainClass;

  String?
      minecraftArguments; // Legacy versions (I'm not entirely sure about the meaning of this)

  //int minimumLauncherVersion
  DateTime releaseTime;
  DateTime time;
  VersionType type;

  VersionData(
      ArgumentsData? arguments,
      AssetsIndex? assetIndex,
      String assets,
      int complianceLevel,
      CoreDownloads downloads,
      String id,
      List<Library> libraries,
      String mainClass,
      String? minecraftArguments,
      DateTime releaseTime,
      DateTime time,
      VersionType type)
      : this.arguments = arguments,
        this.assetIndex = assetIndex,
        this.assets = assets,
        this.complianceLevel = complianceLevel,
        this.downloads = downloads,
        this.id = id,
        this.libraries = libraries,
        this.mainClass = mainClass,
        this.minecraftArguments = minecraftArguments,
        this.releaseTime = releaseTime,
        this.time = time,
        this.type = type;

  Map<String, dynamic> toJson() => _$VersionDataToJson(this);

  factory VersionData.fromJson(Map<String, dynamic> json) =>
      _$VersionDataFromJson(json);
}
