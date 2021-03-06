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

import 'package:flutter/material.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/ui/accounts/account.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/home/home.dart';
import 'package:lilay/ui/screen.dart';
import 'package:provider/provider.dart';

/// [AccountsScreen] shows all the available
/// accounts.
///
/// We don't have any real "screens" in Lilay,
/// "screens" are emulated as "pages" instead,
/// and they always reside in the [Homepage].
class AccountsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    final ThemeData theme = Theme.of(context);

    return Screen(title: 'Accounts', children: [
      for (Account account in accounts.accounts)
        Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: const Offset(2, 2))
                ]),
            child: AccountWidget(account: account, showActions: true))
    ]);
  }
}
