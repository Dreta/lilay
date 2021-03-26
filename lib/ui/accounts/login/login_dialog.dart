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
import 'package:lilay/core/auth/auth_provider.dart';

class LoginDialog extends StatefulWidget {
  final Function(Account) _addAccount;

  LoginDialog({required Function(Account) onAddAccount})
      : _addAccount = onAddAccount;

  @override
  _LoginDialogState createState() =>
      _LoginDialogState(onAddAccount: _addAccount);
}

class _LoginDialogState extends State<LoginDialog> {
  final Function(Account) _addAccount;

  String _selectedAuthProvider = Account.defaultAuthProvider;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loggingIn = false;

  _LoginDialogState({required Function(Account) onAddAccount})
      : _addAccount = onAddAccount;

  @override
  void dispose() {
    super.dispose();
    _username.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO Make the whole dialog more like Google's login dialog when authenticating.
    // FIXME The animation is not fluid on first open

    final theme = Theme.of(context);
    final AuthProvider selected = Account.authProviders[_selectedAuthProvider]!;

    final List<Widget> fields = [];
    if (!selected.useManualAuthentication()) {
      fields.add(TextFormField(
          enabled: !_loggingIn, // Disable the input field if we are logging in
          cursorColor: theme.textSelectionTheme.cursorColor,
          controller: _username,
          decoration: InputDecoration(
              labelText:
                  selected.canUseEmail() ? 'Email / Username' : 'Username',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor)))));

      if (selected.requiresPassword()) {
        // Masking the password is unnecessary.
        fields.add(TextFormField(
            enabled: !_loggingIn,
            cursorColor: theme.textSelectionTheme.cursorColor,
            controller: _password,
            decoration: InputDecoration(
                labelText: 'Password',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor)))));
      }
    }

    return AlertDialog(
        title: const Text('Login'),
        contentPadding: const EdgeInsets.all(24),
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_loggingIn) LinearProgressIndicator(),
          DropdownButtonFormField(
              value: _selectedAuthProvider,
              items: [
                for (final AuthProvider provider
                    in Account.authProviders.values)
                  DropdownMenuItem(
                      value: provider.type, child: Text(provider.name))
              ],
              onChanged:
                  _loggingIn // Disable the dropdown menu if we are logging in
                      ? null
                      : (value) {
                          setState(() {
                            _selectedAuthProvider = value as String;
                          });
                        }),
          for (Widget widget in fields) widget
        ]),
        actions: [
          ElevatedButton(
              onPressed: _loggingIn // Disable the button if we are logging in
                  ? null
                  : () {
                      setState(() => _loggingIn = true);
                      final String? username =
                          selected.useManualAuthentication()
                              ? null
                              : _username.value.text;
                      final String? password =
                          (selected.useManualAuthentication() ||
                                  !selected.requiresPassword())
                              ? null
                              : _password.value.text;
                      final AuthProvider provider =
                          Account.authProviders[_selectedAuthProvider]!;

                      // Login the user
                      provider.login(username, password, (account) {
                        _addAccount(account); // Allow the account to be added
                        _username.clear(); // Clear the fields
                        _password.clear();
                        setState(() {
                          _loggingIn = false;
                          _selectedAuthProvider = Account.defaultAuthProvider;
                          Navigator.pop(context); // Close the dialog
                        });
                      });
                    },
              style: theme.elevatedButtonTheme.style,
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Text(selected.useManualAuthentication()
                      ? 'Continue'
                      : 'Login')))
        ]);
  }
}
