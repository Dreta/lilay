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

class LoginDialogButton extends StatefulWidget {
  @override
  _LoginDialogButtonState createState() => _LoginDialogButtonState();
}

class _LoginDialogButtonState extends State<LoginDialogButton> {
  String _selectedAuthProvider = Account.defaultAuthProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final AuthProvider selected = Account.authProviders[_selectedAuthProvider]!;

    final List<Widget> fields = [];
    if (!selected.useManualAuthentication()) {
      fields.add(TextFormField(
          cursorColor: theme.textSelectionTheme.cursorColor,
          decoration: InputDecoration(
              icon: Icon(Icons.account_circle),
              labelText: 'Email / Username',
              labelStyle: TextStyle(color: theme.accentColor),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor)))));

      if (selected.requiresPassword()) {
        fields.add(TextFormField(
            cursorColor: theme.textSelectionTheme.cursorColor,
            decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
                labelStyle: TextStyle(color: theme.accentColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor)))));
      }
    }

    final AlertDialog dialog = AlertDialog(
        title: Text('Login'),
        contentPadding: EdgeInsets.zero,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField(
              value: _selectedAuthProvider,
              items: [
                for (AuthProvider provider in Account.authProviders.values)
                  DropdownMenuItem(
                      value: provider.type, child: Text(provider.name))
              ],
              onChanged: (value) {
                setState(() => _selectedAuthProvider = value as String);
              }),
          for (Widget widget in fields) widget
        ]),
        actions: [
          TextButton(
              onPressed: () {
                // TODO Log the user in
              },
              child: Text(
                  selected.useManualAuthentication() ? 'CONTINUE' : 'LOGIN',
                  style: textTheme.button))
        ]);

    return ListTile(
        leading: Icon(Icons.add),
        title: Text('Add an account'),
        onTap: () =>
            showDialog<void>(context: context, builder: (context) => dialog));
  }
}
