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

import 'latest_version.dart';
import 'version_info.dart';

part 'version_manifest.g.dart';

/// Contains info available in the version manifest.
@JsonSerializable(explicitToJson: true)
class VersionManifest {
  /// Where the version manifest is located.
  static const String LOCATION = '/mc/game/version_manifest.json';

  LatestVersion latest;
  List<VersionInfo> versions;

  VersionManifest(LatestVersion latest, List<VersionInfo> versions)
      : this.latest = latest,
        this.versions = versions;

  factory VersionManifest.fromJson(Map<String, dynamic> json) =>
      _$VersionManifestFromJson(json);

  Map<String, dynamic> toJson() => _$VersionManifestToJson(this);
}
