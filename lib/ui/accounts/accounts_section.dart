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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/login/login_button.dart';
import 'package:provider/provider.dart';

/// This widget represents the entire accounts section
/// in Lilay.
class AccountsSection extends StatefulWidget {
  @override
  _AccountsSectionState createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<AccountsSection> {
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

    if (accounts.loadingStatus == LoadingStatus.loading) {
      widgets.add(Padding(
          padding: EdgeInsets.only(left: 4),
          child: ListTile(
              leading: Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, backgroundColor: theme.backgroundColor)),
              title: Text('Loading'),
              minLeadingWidth: 17)));
    } else if (accounts.loadingStatus == LoadingStatus.loaded ||
        accounts.loadingStatus == LoadingStatus.failed) {
      if (accounts.selectedAccount != null) {
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
        accounts.addAccount(account);
        for (Account acc in accounts.accounts) {
          acc.selected = false;
        }
        account.selected = true; // The latest account should always be selected
        accounts.selectedAccount = account;
        accounts.saveTo(GetIt.I.get<File>(instanceName: 'accountsDB'));
      }));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
