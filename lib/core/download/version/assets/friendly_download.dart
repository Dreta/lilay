/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
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

part 'friendly_download.g.dart';

/// This class represents a generic download information.
@JsonSerializable(explicitToJson: true)
class FriendlyDownload {
  String? path; // Where the asset will be saved
  String sha1; // The SHA1 checksum of the asset
  int size; // The size of the asset
  String url; // Where to download the asset

  FriendlyDownload(String? path, String sha1, int size, String url)
      : this.path = path,
        this.sha1 = sha1,
        this.size = size,
        this.url = url;

  Map<String, dynamic> toJson() => _$FriendlyDownloadToJson(this);

  factory FriendlyDownload.fromJson(Map<String, dynamic> json) =>
      _$FriendlyDownloadFromJson(json);
}
