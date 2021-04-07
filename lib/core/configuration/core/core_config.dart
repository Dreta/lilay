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

import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:lilay/utils.dart';

part 'core_config.g.dart';

/// Contains core launcher configurations.
@JsonSerializable(explicitToJson: true)
class CoreConfig {
  /// This is where the core config will be loaded from.
  static final File defaultCoreConfig = File('config.json');

  /// The working directory of the launcher. Defaults to .minecraft.
  String workingDirectory;

  /// The type of the background image.
  ///
  /// This is how we know whether we should refer to the asset or
  /// a custom file.
  BackgroundType backgroundType;

  /// The background image that will be shown.
  ///
  /// We will not manually copy the file - the user must maintain
  /// it by himself.
  String? backgroundImage;

  /// Which login type should be the default when the login dialog
  /// is opened.
  ///
  /// Defaults to 'yggdrasil'.
  String preferredLoginType;

  CoreConfig(String? workingDirectory, BackgroundType? backgroundType,
      String? backgroundImage, String? preferredLoginType)
      : this.workingDirectory = workingDirectory ?? getDefaultMinecraft(),
        this.backgroundType = backgroundType ?? BackgroundType.asset,
        this.backgroundImage = backgroundImage,
        this.preferredLoginType = preferredLoginType ?? 'yggdrasil';

  /// Load a new CoreConfig from a file.
  factory CoreConfig.fromFile(File file) {
    // Because this will only be called on startup,
    // using readAsStringSYNC is perfectly fine.
    if (!file.existsSync()) {
      return CoreConfig(null, null, null, null);
    }
    return _$CoreConfigFromJson(jsonDecode(file.readAsStringSync()));
  }

  write(File file) {
    file.writeAsString(jsonEncode(_$CoreConfigToJson(this)));
  }

  Map<String, dynamic> toJson() => _$CoreConfigToJson(this);
}
