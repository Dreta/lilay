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
import 'package:lilay/ui/home/home.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);

    return MaterialApp(
        title: 'Lilay',
        theme: ThemeData(
            brightness: config.darkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.primaries[config.accent],
            accentColor: Colors.primaries[config.accent],
            primaryColor: config.darkMode ? Colors.black : Colors.white,
            primaryColorDark: config.darkMode ? null : Colors.white70,
            primaryColorLight: config.darkMode ? Colors.black87 : null,
            primaryColorBrightness:
                config.darkMode ? Brightness.dark : Brightness.light),
        home: Homepage());
  }
}
