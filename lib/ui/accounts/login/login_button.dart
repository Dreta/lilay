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
import 'package:lilay/ui/accounts/login/login_dialog.dart';

class LoginButton extends StatelessWidget {
  final Function(Account) _addAccount;

  LoginButton({required Function(Account) onAddAccount})
      : _addAccount = onAddAccount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.add),
        title: Text('Add an account'),
        minLeadingWidth: 20,
        onTap: () => {LoginDialog.display(context, _addAccount)});
  }
}
