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

part 'classifiers_download.g.dart';

@JsonSerializable(explicitToJson: true)
class ClassifiersDownload {
  @JsonKey(name: 'javadoc')
  FriendlyDownload? javadocs;

  @JsonKey(name: 'natives-linux')
  FriendlyDownload? nativesLinux;

  @JsonKey(name: 'natives-macos')
  FriendlyDownload? nativesMacOS;

  @JsonKey(name: 'natives-windows')
  FriendlyDownload? nativesWindows;

  @JsonKey(name: 'sources')
  FriendlyDownload? sources;

  ClassifiersDownload(
      FriendlyDownload? javadocs,
      FriendlyDownload? nativesLinux,
      FriendlyDownload? nativesMacOS,
      FriendlyDownload? nativesWindows,
      FriendlyDownload? sources)
      : this.javadocs = javadocs,
        this.nativesLinux = nativesLinux,
        this.nativesMacOS = nativesMacOS,
        this.nativesWindows = nativesWindows,
        this.sources = sources;

  Map<String, dynamic> toJson() => _$ClassifiersDownloadToJson(this);

  factory ClassifiersDownload.fromJson(Map<String, dynamic> json) =>
      _$ClassifiersDownloadFromJson(json);
}
