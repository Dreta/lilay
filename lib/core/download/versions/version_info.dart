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

part 'version_info.g.dart';

/// Contains info about a game version available in the version manifest.
@JsonSerializable(explicitToJson: true)
class VersionInfo {
  String id;
  VersionType type;
  String url;
  DateTime time;
  DateTime releaseTime;

  VersionInfo(String id, VersionType type, String url, DateTime time,
      DateTime releaseTime)
      : this.id = id,
        this.type = type,
        this.url = url,
        this.time = time,
        this.releaseTime = releaseTime;

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);
}

/// The possible types of a [VersionInfo].
enum VersionType { snapshot, release, old_beta, old_alpha }
