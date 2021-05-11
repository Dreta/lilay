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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/accounts_section.dart';
import 'package:lilay/ui/configuration/configuration_section.dart';
import 'package:lilay/ui/home/profile.dart';
import 'package:provider/provider.dart';

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
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Lilay', style: textTheme.headline5)),
                      Divider(
                          height: 1, thickness: 1, color: theme.dividerColor),

                      // Accounts
                      AccountsSection(),

                      // Profiles
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 5),
                          child: Text('PROFILES', style: textTheme.subtitle2)),
                      Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.dividerColor)),
                      Profile(name: 'Fabric 1.16.5', modded: true),
                      Profile(name: 'Vanilla 1.16.5'),

                      ConfigurationSection(),

                      if (accounts.loadingStatus == LoadingStatus.failed)
                        Expanded(
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: ListTile(
                                  leading: Icon(Icons.error,
                                      color: theme.errorColor),
                                  title: Text('Failed to load',
                                      style:
                                          TextStyle(color: theme.errorColor)),
                                  minLeadingWidth: 20,
                                )))
                    ])))));
  }
}
