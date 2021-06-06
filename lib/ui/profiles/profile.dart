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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:provider/provider.dart';

/// This widget represents a game profile in Lilay.
class ProfileWidget extends StatelessWidget {
  final Profile profile;
  final bool showActions;
  final bool openScreen;

  const ProfileWidget(
      {required this.profile,
      this.openScreen = false,
      this.showActions = false});

  @override
  Widget build(BuildContext context) {
    final ScreenProvider screen = Provider.of<ScreenProvider>(context);
    final ProfilesProvider profiles = Provider.of<ProfilesProvider>(context);
    final ThemeData theme = Theme.of(context);

    Widget? trailingWidget;
    if (openScreen) {
      trailingWidget = Icon(Icons.menu);
    } else if (showActions) {
      trailingWidget = Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            icon: Icon(Icons.edit), tooltip: 'Edit', onPressed: () {} // TODO
            ),
        IconButton(
            icon: Icon(Icons.delete),
            color: theme.errorColor,
            tooltip: 'Delete',
            onPressed: () {} // TODO
            )
      ]);
    }

    void Function()? onTapAction;
    if (openScreen) {
      // toggle the profiles screen
      onTapAction = () => screen.current = screen.current == ScreenType.profiles
          ? ScreenType.home
          : ScreenType.profiles;
    } else if (showActions) {
      onTapAction = () {
        for (Profile profile in profiles.profiles) {
          profile.selected = false;
        }
        profile.selected = true;
        profiles.selected = profile;
        profiles.saveTo(GetIt.I.get<File>(instanceName: 'profilesDB'));
      };
    }

    return ListTile(
        leading: Icon(Icons.sports_esports, color: theme.accentColor),
        trailing: trailingWidget,
        title: Text(profile.name),
        subtitle: Text(profile.version),
        onTap: onTapAction,
        selected: showActions ? profile.selected : false,
        minLeadingWidth: 20);
  }
}
