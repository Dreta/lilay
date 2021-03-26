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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/main.dart';
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/accounts/login/login_button.dart';

/// This is where the account database will be loaded from.
File defaultAccountDB = File('accounts.json');

/// This widget represents the entire accounts section
/// in Lilay.
class AccountsSection extends StatefulWidget {
  @override
  _AccountsSectionState createState() =>
      _AccountsSectionState(file: defaultAccountDB);
}

class _AccountsSectionState extends State<AccountsSection> {
  final File _file;
  final _accounts = <Account>[];

  _AccountsSectionState({required File file}) : _file = file {
    if (file.existsSync()) {
      _load(file);
    }
  }

  /// Load the saved accounts from a file.
  void _load(File file) async {
    for (Map<String, dynamic> account
        in (jsonDecode(await file.readAsString())['accounts']
            as List<dynamic>)) {
      String? type = account['type'];
      if (type == null) {
        logger.severe('Found invalid account without type');
        continue;
      }
      _accounts.add(Account.accountFactories[type]!(account));
    }
  }

  /// Save the accounts to the data file.
  void _save() async {
    // TODO It won't save / won't load
    List<Map<String, dynamic>> json = [];
    for (Account account in _accounts) {
      json.add(account.toJson());
    }
    await _file.writeAsString(jsonEncode({'accounts': json}));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    List<Widget> widgets = [
      Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
          child: Text('ACCOUNTS', style: textTheme.subtitle2)),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor))
    ];

    // TODO Add a dedicated screen for all the accounts.
    for (Account account in _accounts) {
      if (account.selected) {
        widgets
            .add(AccountWidget(name: account.profileName, showMenuIcon: true));
        break;
      }
    }

    widgets.add(LoginButton(onAddAccount: (account) {
      setState(() {
        _accounts.add(account);
        account.selected = true; // The latest account should always be selected
        _save();
      });
    }));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
