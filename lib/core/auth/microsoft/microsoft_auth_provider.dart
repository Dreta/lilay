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

import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_server.dart';
import 'package:open_url/open_url.dart';

/// MicrosoftAuthProvider logs a user into their Microsoft account.
class MicrosoftAuthProvider extends AuthProvider {
  final MicrosoftAuthServer _authServer;

  MicrosoftAuthProvider({required MicrosoftAuthServer authServer})
      : _authServer = authServer;

  @override
  login(String? username, String? password, Function(Account) callback,
      Function(String) error) {
    // This is where we will have to visit.
    String authUrl =
        'https://login.live.com/oauth20_authorize.srf?client_id=${MicrosoftAccount.CLIENT_ID}'
        '&response_type=code'
        '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'
        '&scope=XboxLive.signin%20offline_access';

    // Open the browser window.
    openUrl(authUrl);

    // Make the auth server use the callback we have from the user.
    _authServer.accountCallback = callback;
    _authServer.errorCallback = error;
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
