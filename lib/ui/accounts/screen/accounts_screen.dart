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
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/home/home.dart';

/// This is the screen for a list of available
/// accounts in Lilay.
///
/// We don't have any real "screens" in Lilay,
/// "screens" are emulated as "pages" instead,
/// and they always reside in the [Homepage].
class AccountsScreen extends StatelessWidget {
  final List<Account> accounts;
  // This will be called after a confirmation dialog is shown.
  final Function(Account) onAccountDelete;

  const AccountsScreen({required this.accounts, required this.onAccountDelete});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accounts', style: textTheme.headline2),
              Divider(height: 1, thickness: 1, color: theme.dividerColor),
              ListView(padding: EdgeInsets.zero, children: [
                for (Account account in accounts)
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                blurRadius: 25,
                                spreadRadius: 5,
                                offset: Offset(15, 15))
                          ]),
                      child: AccountWidget(
                          account: account,
                          showActions: true,
                          onAccountDelete: () => onAccountDelete(account)))
              ])
            ]));
  }
}
