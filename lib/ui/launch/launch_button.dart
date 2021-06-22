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
import 'package:lilay/core/profile/game_manager.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/ui/launch/launch_dialog.dart';
import 'package:lilay/ui/launch/launch_provider.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:provider/provider.dart';

class LaunchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LaunchProvider launch = Provider.of<LaunchProvider>(context);
    final ProfilesProvider profiles = Provider.of<ProfilesProvider>(context);
    final CoreConfig config = Provider.of<CoreConfig>(context);
    final ThemeData theme = Theme.of(context);

    String text;
    if (launch.status == LaunchStatus.starting) {
      text = 'STARTING';
    } else if (launch.status == LaunchStatus.started) {
      text = 'RUNNING';
    } else {
      text = 'START';
    }

    return FloatingActionButton.extended(
        label: Text(text, style: theme.textTheme.button),
        onPressed: () {
          if (launch.status == null || launch.status == LaunchStatus.started) {
            Profile profile = profiles.selected!;
            GameManager manager =
                GameManager(profile: profile, config: config, parent: launch);
            launch.manager = manager;
            launch.status = LaunchStatus.starting;
            manager.startDownload();
            launch.notify();
          }
          LaunchDialog.display(context);
        },
        backgroundColor: theme.scaffoldBackgroundColor,
        icon: Icon(Icons.send, color: theme.accentColor));
  }
}
