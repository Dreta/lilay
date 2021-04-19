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
import 'package:lilay/ui/home/navigation_drawer.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:provider/provider.dart';

/// This is the part for the configuration screen
/// in the [NavigationDrawer].
class ConfigurationSection extends StatelessWidget {
  Widget build(BuildContext context) {
    final ScreenProvider screen = Provider.of<ScreenProvider>(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
          child: Text('ACCOUNTS', style: textTheme.subtitle2)),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor)),
      ListTile(
          leading: Icon(Icons.settings, color: theme.accentColor),
          title: Text('Settings'),
          minLeadingWidth: 20,
          onTap: () => screen.current = ScreenType.configuration)
    ]);
  }
}
