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
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_server.dart';
import 'package:lilay/ui/accounts/login/microsoft/microsoft_dialog.dart';

/// MicrosoftAuthProvider logs a user into their Microsoft account.
class MicrosoftAuthProvider extends AuthProvider {
  final MicrosoftAuthServer authServer;
  final Function(String) openUrl;

  MicrosoftAuthProvider({required this.authServer, required this.openUrl});

  @override
  Future<void> login(
      BuildContext? context,
      String? username,
      String? password,
      Function(Account) callback,
      Function(String) error,
      Client? client) async {
    if (context == null) {
      error('Build context must not be null.');
      return;
    }

    MicrosoftDialog.display(context, openUrl);

    // Make the auth server use the callback we have from the user.
    authServer.accountCallback = callback;
    authServer.errorCallback = error;
  }

  @override
  bool get requiresPassword => false;

  @override
  bool get useManualAuthentication => true;

  @override
  String get name => 'Microsoft';

  @override
  String get type => 'microsoft';
}
