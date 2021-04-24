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
import 'package:provider/provider.dart';

class DarkMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);
    final ThemeData theme = Theme.of(context);

    return Row(children: [
      Expanded(
          child: Row(
              children: [Text('Dark Mode', style: TextStyle(fontSize: 16))])),
      Switch(
          value: config.darkMode,
          activeColor: theme.accentColor,
          onChanged: (dark) {
            config.darkMode = dark;
            config.save();
            config.write(CoreConfig.defaultCoreConfig);
          })
    ]);
  }
}
