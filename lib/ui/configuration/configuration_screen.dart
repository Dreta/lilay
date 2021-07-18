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

import 'package:flutter/material.dart';
import 'package:lilay/ui/configuration/options/accent.dart';
import 'package:lilay/ui/configuration/options/assets_source.dart';
import 'package:lilay/ui/configuration/options/background_image.dart';
import 'package:lilay/ui/configuration/options/core_source.dart';
import 'package:lilay/ui/configuration/options/dark_mode.dart';
import 'package:lilay/ui/configuration/options/libraries_source.dart';
import 'package:lilay/ui/configuration/options/meta_source.dart';
import 'package:lilay/ui/configuration/options/preferred_login_type.dart';
import 'package:lilay/ui/configuration/options/show_snapshots.dart';
import 'package:lilay/ui/screen.dart';

/// This screen shows the list of configuration
/// options in Lilay.
class ConfigurationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Screen(title: 'Settings', children: [
      BackgroundImage(),
      PreferredLoginType(),
      DarkMode(),
      CoreSource(),
      MetaSource(),
      AssetsSource(),
      LibrariesSource(),
      Padding(padding: EdgeInsets.only(top: 12), child: AccentColor()),
      Padding(padding: EdgeInsets.only(top: 12), child: ShowSnapshots())
    ]);
  }
}
