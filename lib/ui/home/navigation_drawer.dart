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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/accounts_section.dart';
import 'package:lilay/ui/configuration/configuration_section.dart';
import 'package:lilay/ui/profiles/profiles_section.dart';
import 'package:provider/provider.dart';

import 'error_tile.dart';

/// This is the navigation drawer always shown in Lilay.
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Theme(
        data: theme.copyWith(
            canvasColor: theme.scaffoldBackgroundColor.withOpacity(0.8)),
        child: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Drawer(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(
                          child: ListView(children: [
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Lilay', style: textTheme.headline5)),
                        Divider(
                            height: 1, thickness: 1, color: theme.dividerColor),

                        // Sections
                        AccountsSection(),
                        ProfilesSection(),
                        ConfigurationSection(),
                      ])),
                      Container(
                          child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Container(
                                  child: Column(children: [
                                if (accounts.loadingStatus ==
                                    LoadingStatus.failed)
                                  ErrorTile(message: 'Disconnected'),
                                if (GetIt.I
                                    .get<String>(instanceName: 'java')
                                    .isEmpty)
                                  ErrorTile(message: 'Java not found')
                              ]))))
                    ])))));
  }
}
