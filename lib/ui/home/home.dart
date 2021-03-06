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

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/screen/accounts_screen.dart';
import 'package:lilay/ui/animated_screen.dart';
import 'package:lilay/ui/configuration/configuration_screen.dart';
import 'package:lilay/ui/home/navigation_drawer.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:lilay/ui/launch/launch_button.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:lilay/ui/profiles/screen/profiles_screen.dart';
import 'package:provider/provider.dart';

/// This widget represents the main page of Lilay,
/// consisting of the accounts, the game profiles
/// and the play button.
class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FileSystem fs = GetIt.I.get<FileSystem>();
    final CoreConfig config = Provider.of<CoreConfig>(context);
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    final ProfilesProvider profiles = Provider.of<ProfilesProvider>(context);

    ImageProvider background;
    if (config.backgroundType == BackgroundType.custom) {
      File file = fs.file(config.backgroundImage!);
      if (!file.existsSync()) {
        background = AssetImage('assets/background.png');
      } else {
        background = FileImage(file);
      }
    } else {
      background = AssetImage('assets/background.png');
    }

    return Scaffold(
        floatingActionButton:
            profiles.selected != null && accounts.selectedAccount != null
                ? LaunchButton()
                : null,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(image: background, fit: BoxFit.cover)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              NavigationDrawer(),
              Expanded(
                  child: Stack(children: [
                AnimatedScreen(
                    screenType: ScreenType.accounts, child: AccountsScreen()),
                AnimatedScreen(
                    screenType: ScreenType.profiles, child: ProfilesScreen()),
                AnimatedScreen(
                    screenType: ScreenType.configuration,
                    child: ConfigurationScreen())
              ]))
            ])));
  }
}
