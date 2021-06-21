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

import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'asset.g.dart';

/// Represents a downloadable asset.
@JsonSerializable(explicitToJson: true)
class Asset {
  String hash;
  int size;

  Asset(String hash, int size)
      : this.hash = hash,
        this.size = size;

  String path(String workingDir) =>
      '$workingDir${Platform.pathSeparator}assets${Platform.pathSeparator}objects${Platform.pathSeparator}${hash.substring(0, 2)}${Platform.pathSeparator}$hash';

  String url(String source) => '$source/${hash.substring(0, 2)}/$hash';

  Map<String, dynamic> toJson() => _$AssetToJson(this);

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}
