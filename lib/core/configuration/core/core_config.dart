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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:lilay/utils.dart';

part 'core_config.g.dart';

/// Contains core launcher configurations.
@JsonSerializable(explicitToJson: true)
class CoreConfig extends ChangeNotifier {
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
  /// it by themselves.
  String? backgroundImage;

  /// Which login type should be the default when the login dialog
  /// is opened.
  ///
  /// Defaults to 'yggdrasil'.
  String preferredLoginType;

  /// The accent color for this app. This is the index for the list
  /// [Colors.primaries].
  ///
  /// Defaults to the blue accent.
  int accent;

  /// Whether dark mode should be activated for this app.
  ///
  /// Defaults to follow system settings.
  DarkModeType darkMode;

  /// The source to download game metadata from.
  ///
  /// Do not include the slash (/) at the end of the URL.
  /// Defaults to https://launchermeta.mojang.com.
  String downloadSource;

  /// The source to download game assets from.
  ///
  /// Do not include the slash (/) at the end of the URL.
  /// Defaults to https://resources.download.minecraft.net.
  String assetsSource;

  /// The source to download game libraries from.
  ///
  /// Do not include the slash (/) at the end of the URL.
  /// Defaults to https://libraries.minecraft.net.
  String librariesSource;

  CoreConfig(
      String? workingDirectory,
      BackgroundType? backgroundType,
      String? backgroundImage,
      String? preferredLoginType,
      int? accent,
      DarkModeType? darkMode,
      String? downloadSource,
      String? assetsSource,
      String? librariesSource)
      : this.workingDirectory = workingDirectory ?? getDefaultMinecraft(),
        this.backgroundType = backgroundType ?? BackgroundType.asset,
        this.backgroundImage = backgroundImage,
        this.preferredLoginType = preferredLoginType ?? 'yggdrasil',
        this.accent = accent ?? 5,
        this.darkMode = darkMode ?? DarkModeType.system,
        this.downloadSource =
            downloadSource ?? 'https://launchermeta.mojang.com',
        this.assetsSource =
            assetsSource ?? 'https://resources.download.minecraft.net',
        this.librariesSource =
            librariesSource ?? 'https://libraries.minecraft.net';

  /// Load a new CoreConfig from a file.
  factory CoreConfig.fromFile(File file) {
    if (!file.existsSync()) {
      return CoreConfig(null, null, null, null, null, null, null, null, null);
    }
    return _$CoreConfigFromJson(jsonDecode(file.readAsStringSync()));
  }

  write(File file) {
    file.writeAsString(jsonEncode(_$CoreConfigToJson(this)));
  }

  Map<String, dynamic> toJson() => _$CoreConfigToJson(this);

  save() {
    notifyListeners();
    write(defaultCoreConfig);
  }
}
