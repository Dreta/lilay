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
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/screen/accounts_screen.dart';
import 'package:lilay/ui/accounts/screen/delete_dialog.dart';
import 'package:lilay/ui/home/home.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// This widget represents an account in Lilay.
class AccountWidget extends StatefulWidget {
  final Account account;

  /// Whether clicking on this [AccountWidget] will open
  /// the [AccountsScreen].
  ///
  /// If true, a trailing "menu" icon will be shown and
  /// when clicked, the [AccountsScreen] in the parent
  /// [Homepage] will be opened.
  final bool openScreen;

  /// Whether the trailing "refresh" and "delete" actions
  /// will be shown for this widget.
  final bool showActions;

  /// This function will be called when the user attempts
  /// to delete the [account].
  ///
  /// Must be specified if [showActions] is true.
  final Function? onAccountDelete;

  AccountWidget(
      {required this.account,
      this.openScreen = false,
      this.showActions = false,
      this.onAccountDelete})
      : super(key: Key(account.uuid));

  @override
  _AccountWidgetState createState() {
    return _AccountWidgetState(
        account: account,
        openScreen: openScreen,
        showActions: showActions,
        onAccountDelete: onAccountDelete);
  }
}

class _AccountWidgetState extends State<AccountWidget> {
  final Account _account;
  final bool _openScreen;
  final bool _showActions;
  bool _isRefreshing = false;

  // This will be called after a confirmation dialog is shown.
  final Function? _onAccountDelete;
  late File _cachedSkinPath;

  _AccountWidgetState(
      {required Account account,
      required bool openScreen,
      required bool showActions,
      Function? onAccountDelete})
      : _account = account,
        _openScreen = openScreen,
        _showActions = showActions,
        _onAccountDelete = onAccountDelete {
    _cachedSkinPath = File(
        '${GetIt.I.get<Directory>(instanceName: 'cache').absolute.path}${Platform.pathSeparator}${_account.uuid}.png');

    if (account.authProvider.requiresPayment && account.paid) {
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
    final ScreenProvider screen = Provider.of<ScreenProvider>(context);
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    final ThemeData theme = Theme.of(context);

    Widget? trailingWidget;
    if (_openScreen) {
      trailingWidget = Icon(Icons.menu);
    } else if (_showActions) {
      trailingWidget = _isRefreshing
          ? Container(
              child: CircularProgressIndicator(strokeWidth: 2),
              width: 15,
              height: 15,
              margin: EdgeInsets.only(right: 12))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (_account.authProvider.onlineAuth)
                IconButton(
                    icon: Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () async {
                      setState(() => _isRefreshing = true);
                      await _account.refresh();
                      setState(() => _isRefreshing = false);
                    }),
              IconButton(
                  icon: Icon(Icons.delete),
                  color: theme.errorColor,
                  tooltip: 'Delete',
                  onPressed: () =>
                      DeleteDialog.display(context, () => _onAccountDelete!()))
            ]);
    }

    void Function()? onTapAction;
    if (_openScreen) {
      // toggle the accounts screen
      onTapAction = () => screen.current = screen.current == ScreenType.accounts
          ? ScreenType.home
          : ScreenType.accounts;
    } else if (_showActions) {
      onTapAction = () {
        // select the current account
        for (Account acc in accounts.accounts) {
          acc.selected = false;
        }
        _account.selected = true;
        accounts.selectedAccount = _account;
      };
    }

    return ListTile(
        leading: _cachedSkinPath.existsSync()
            ? ClipRRect(
                // Fully rounded skin display
                borderRadius: BorderRadius.circular(24 / 2),
                child: Image.file(_cachedSkinPath, width: 24, height: 24))
            : Icon(Icons.account_circle, color: theme.accentColor),
        trailing: trailingWidget,
        title: Text(_account.profileName,
            style: _account.requiresReauth
                ? TextStyle(color: theme.errorColor)
                : null),
        subtitle: _account.requiresReauth // If re-auth is required
            ? Text('Re-login required', // Show the message
                style: TextStyle(color: theme.errorColor))
            : Text(_account.authProvider.name),
        minLeadingWidth: 20,
        onTap: onTapAction);
  }
}
