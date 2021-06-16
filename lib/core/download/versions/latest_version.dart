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

part 'latest_version.g.dart';

/// Contains info about the latest version of the game.
@JsonSerializable(explicitToJson: true)
class LatestVersion {
  String release;
  String snapshot;

  LatestVersion(String release, String snapshot)
      : this.release = release,
        this.snapshot = snapshot;

  factory LatestVersion.fromJson(Map<String, dynamic> json) =>
      _$LatestVersionFromJson(json);

  Map<String, dynamic> toJson() => _$LatestVersionToJson(this);
}
