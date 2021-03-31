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
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:logging/logging.dart';

/// This widget represents an account in Lilay.
class AccountWidget extends StatefulWidget {
  final Account account;

  /// Whether the menu icon will be shown.
  /// The menu icon should be shown for the selected account in the
  /// navigation drawer.
  final bool showMenuIcon;

  AccountWidget({required this.account, this.showMenuIcon = false})
      : super(key: Key(account.uuid));

  @override
  _AccountWidgetState createState() {
    return _AccountWidgetState(account: account, showMenuIcon: showMenuIcon);
  }
}

class _AccountWidgetState extends State<AccountWidget> {
  final Account _account;
  final bool _showMenuIcon;
  late File _cachedSkinPath;

  _AccountWidgetState({required Account account, required bool showMenuIcon})
      : _account = account,
        _showMenuIcon = showMenuIcon {
    _cachedSkinPath = File(
        '${GetIt.I.get<Directory>(instanceName: 'cache').absolute.path}${Platform.pathSeparator}${_account.uuid}.png');

    if (account.authProvider.requiresPayment) {
      GetIt.I
          .get<Logger>()
          .info('Attempting to get skin from ${_account.uuid}.');
      get(
          Uri.parse(
              'https://crafatar.com/avatars/${_account.uuid}?size=24&overlay=nevergonnaletyoudown'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher'
          }).then((resp) async {
        GetIt.I.get<Logger>().info('Received skin response.');
        await _cachedSkinPath.writeAsBytes(List.from(resp.bodyBytes));
        setState(() {}); // Force refresh of widget
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
        leading: _cachedSkinPath.existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24 / 2),
                child: Image.file(_cachedSkinPath, width: 24, height: 24))
            : Icon(Icons.account_circle, color: theme.accentColor),
        trailing: (_showMenuIcon ? Icon(Icons.menu) : null),
        title: Text(_account.profileName,
            style: _account.requiresReauth
                ? TextStyle(color: theme.errorColor)
                : null),
        subtitle: _account.requiresReauth // If re-auth is required
            ? Text('Re-login required', // Show the message
                style: TextStyle(color: theme.errorColor))
            : Text(_account.authProvider.name),
        minLeadingWidth: 20);
  }
}
