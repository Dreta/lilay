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
import 'package:lilay/core/download/version/assets/friendly_download.dart';

import 'artifact.dart';

part 'lib_download_info.g.dart';

/// Represents the download information for this library.
///
/// Might not be available. In case it isn't available, the download
/// information must be extracted through [Artifact].
@JsonSerializable(explicitToJson: true)
class LibDownloadInfo {
  FriendlyDownload? artifact;
  Map<String, dynamic> classifiers; // This is completely dynamic.

  LibDownloadInfo(FriendlyDownload? artifact, Map<String, dynamic>? classifiers)
      : this.artifact = artifact,
        this.classifiers = classifiers ?? {};

  Map<String, dynamic> toJson() => _$LibDownloadInfoToJson(this);

  factory LibDownloadInfo.fromJson(Map<String, dynamic> json) =>
      _$LibDownloadInfoFromJson(json);
}
