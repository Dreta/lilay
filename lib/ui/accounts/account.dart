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

/// This widget represents an account in Lilay.
class AccountWidget extends StatelessWidget {
  final Account account;

  /// Whether the menu icon will be shown.
  /// The menu icon should be shown for the selected account in the
  /// navigation drawer.
  final bool showMenuIcon;

  const AccountWidget({required this.account, this.showMenuIcon = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
        // TODO Use the user's skin as icon instead.
        leading: Icon(Icons.account_circle, color: theme.accentColor),
        trailing: (showMenuIcon ? Icon(Icons.menu) : null),
        title: Text(account.profileName,
            style: account.requiresReauth
                ? TextStyle(color: theme.errorColor)
                : null),
        subtitle: account.requiresReauth // If re-auth is required
            ? Text('Re-login required', // Show the message
                style: TextStyle(color: theme.errorColor))
            : Text(account.authProvider.name),
        minLeadingWidth: 20);
  }
}
