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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/ui/accounts/accounts_section.dart';
import 'package:lilay/ui/accounts/screen/accounts_screen.dart';
import 'package:lilay/ui/home/profile.dart';

/// This widget represents the main page of Lilay,
/// consisting of the accounts, the game profiles
/// and the play button.
class Homepage extends InheritedWidget {
  final List<Account> accounts = [];

  Homepage() : super(child: _HomepageWidget());

  static Homepage? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<Homepage>();

  @override
  bool updateShouldNotify(covariant Homepage old) {
    return old.accounts == accounts;
  }
}

class _HomepageWidget extends StatefulWidget {
  @override
  _HomepageWidgetState createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<_HomepageWidget> {
  String? _selectedScreen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
        body: Row(children: [
      Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Lilay', style: textTheme.headline5)),
        Divider(height: 1, thickness: 1, color: theme.dividerColor),

        // Accounts
        AccountsSection(),

        // Profiles
        Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
            child: Text('PROFILES', style: textTheme.subtitle2)),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Divider(height: 1, thickness: 1, color: theme.dividerColor)),
        Profile(name: 'Fabric 1.16.5', modded: true),
        Profile(name: 'Vanilla 1.16.5')
      ])),
      if (_selectedScreen == 'accounts')
        AccountsScreen(
            accounts: Homepage.of(context)!.accounts,
            onAccountDelete: (account) =>
                Homepage.of(context)!.accounts.remove(account))
    ]));
  }
}
