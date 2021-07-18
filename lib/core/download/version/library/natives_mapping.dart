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

part 'natives_mapping.g.dart';

/// This class represents the mapping of the natives
/// from the platform to the name in [classifiers].
///
/// The mapped natives should have the ${arch} replaced
/// with the kernel bitness (32/64)
@JsonSerializable(explicitToJson: true)
class NativesMapping {
  String? windows;
  String? osx;
  String? linux;

  NativesMapping(String? windows, String? osx, String? linux)
      : this.windows = windows,
        this.osx = osx,
        this.linux = linux;

  Map<String, dynamic> toJson() => _$NativesMappingToJson(this);

  factory NativesMapping.fromJson(Map<String, dynamic> json) =>
      _$NativesMappingFromJson(json);
}
