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
import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/accounts/login/login_button.dart';
import 'package:logging/logging.dart';

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
  final List<Account> _accounts = [];
  bool _loading = true;
  bool _loadingFailed = false;
  Account? _selectedAccount;

  _AccountsSectionState({required File file}) : _file = file {
    if (file.existsSync()) {
      _load(file);
    } else {
      _loading = false;
    }
  }

  /// Load the saved accounts from a file.
  _load(File file) async {
    for (Map<String, dynamic> account
        in (jsonDecode(await file.readAsString())['accounts']
            as List<dynamic>)) {
      String? type = account['type'];
      if (type == null) {
        GetIt.I.get<Logger>().severe('Found invalid account without type');
        continue;
      }
      Account acc = Account.accountFactories[account['type']]!(account);
      try {
        await acc.refresh();
      } catch (e) {
        setState(() => _loadingFailed = true);
        break;
      }
      setState(() {
        if (acc.selected) {
          _selectedAccount = acc;
        }
        _accounts.add(acc);
      });
    }
    setState(() => _loading = false);
  }

  /// Save the accounts to the data file.
  _save() async {
    List<Map<String, dynamic>> json = [];
    for (Account account in _accounts) {
      json.add(account.toJson());
    }
    await _file.writeAsString(jsonEncode({'accounts': json}));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    List<Widget> widgets = [
      Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
          child: Text('ACCOUNTS', style: textTheme.subtitle2)),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor))
    ];

    if (_loadingFailed) {
      widgets.add(ListTile(
        leading: Icon(Icons.error, color: theme.errorColor),
        title:
            Text('Failed to load', style: TextStyle(color: theme.errorColor)),
        minLeadingWidth: 20,
      ));
    }

    if (_loading && !_loadingFailed) {
      widgets.add(Padding(
          padding: EdgeInsets.only(left: 4),
          child: ListTile(
              leading: Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              title: Text('Loading'),
              minLeadingWidth: 17)));
    } else if (!_loadingFailed) {
      // TODO Add a dedicated screen for all the accounts.
      if (_selectedAccount != null) {
        widgets
            .add(AccountWidget(account: _selectedAccount!, openScreen: true));
      }

      widgets.add(LoginButton(onAddAccount: (account) {
        for (Account acc in _accounts) {
          if (acc.uuid == account.uuid && !acc.requiresReauth) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('This account already exist!'),
                duration: Duration(seconds: 2)));
            return;
          }
        }
        setState(() {
          _accounts.add(account);
          for (Account acc in _accounts) {
            acc.selected = false;
          }
          account.selected =
              true; // The latest account should always be selected
          _selectedAccount = account;
          _save();
        });
      }));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
