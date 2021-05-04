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

import 'package:flutter/material.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:provider/provider.dart';

/// ThemedUI manages the user interface theme state in Lilay.
class ThemedUI extends StatelessWidget {
  final Widget child;

  const ThemedUI({required this.child});

  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);
    final bool darkMode = config.darkMode == DarkModeType.dark ||
        (config.darkMode == DarkModeType.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Theme(
        data: ThemeData(
            brightness: darkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.primaries[config.accent],
            accentColor: Colors.primaries[config.accent]),
        child: child);
  }
}
