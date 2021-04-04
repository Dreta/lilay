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
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/login/login_button.dart';
import 'package:provider/provider.dart';

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

  _AccountsSectionState({required File file}) : _file = file {
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    accounts.loadFrom(file);
  }

  /// Save the accounts to the data file.
  _save() async {
    // TODO Move this to AccountsProvider
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    List<Map<String, dynamic>> json = [];
    for (Account account in accounts.accounts) {
      json.add(account.toJson());
    }
    await _file.writeAsString(jsonEncode({'accounts': json}));
  }

  @override
  Widget build(BuildContext context) {
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);

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

    if (accounts.loadingStatus == LoadingStatus.failed) {
      widgets.add(ListTile(
        leading: Icon(Icons.error, color: theme.errorColor),
        title:
            Text('Failed to load', style: TextStyle(color: theme.errorColor)),
        minLeadingWidth: 20,
      ));
    }

    if (accounts.loadingStatus == LoadingStatus.loading) {
      widgets.add(Padding(
          padding: EdgeInsets.only(left: 4),
          child: ListTile(
              leading: Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              title: Text('Loading'),
              minLeadingWidth: 17)));
    } else if (accounts.loadingStatus == LoadingStatus.loaded) {
      if (accounts.selectedAccountUUID != null) {
        widgets.add(AccountWidget(
            account: accounts.selectedAccount!, openScreen: true));
      }

      widgets.add(LoginButton(onAddAccount: (account) {
        for (Account acc in accounts.accounts) {
          if (acc.uuid == account.uuid && !acc.requiresReauth) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('This account already exist!'),
                duration: Duration(seconds: 2)));
            return;
          }
        }
        setState(() {
          accounts.addAccount(account);
          for (Account acc in accounts.accounts) {
            acc.selected = false;
          }
          account.selected =
              true; // The latest account should always be selected
          accounts.selectedAccountUUID = account.uuid;
          _save();
        });
      }));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
