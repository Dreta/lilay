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

part 'core_downloads.g.dart';

@JsonSerializable(explicitToJson: true)
class CoreDownloads {
  FriendlyDownload client;
  @JsonKey(name: 'client_mappings')
  FriendlyDownload? clientMappings;
  FriendlyDownload? server;
  @JsonKey(name: 'server_mappings')
  FriendlyDownload? serverMappings;

  CoreDownloads(FriendlyDownload client, FriendlyDownload? clientMappings,
      FriendlyDownload? server, FriendlyDownload? serverMappings)
      : this.client = client,
        this.clientMappings = clientMappings,
        this.server = server,
        this.serverMappings = serverMappings;

  Map<String, dynamic> toJson() => _$CoreDownloadsToJson(this);

  factory CoreDownloads.fromJson(Map<String, dynamic> json) =>
      _$CoreDownloadsFromJson(json);
}
