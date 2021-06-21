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

part 'assets_index.g.dart';

/// Represents the asset index field WITHIN THE VERSION MANIFEST.
@JsonSerializable(explicitToJson: true)
class AssetsIndex {
  String id;
  String sha1;
  int size; // The size of the assets index file
  int totalSize; // The size of all required assets
  String url;

  AssetsIndex(String id, String sha1, int size, int totalSize, String url)
      : this.id = id,
        this.sha1 = sha1,
        this.size = size,
        this.totalSize = totalSize,
        this.url = url;

  Map<String, dynamic> toJson() => _$AssetsIndexToJson(this);

  factory AssetsIndex.fromJson(Map<String, dynamic> json) =>
      _$AssetsIndexFromJson(json);
}
