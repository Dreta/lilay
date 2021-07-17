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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/ui/accounts/login/microsoft/microsoft_dialog.dart';

import 'microsoft_account.dart';

/// MicrosoftAuthProvider logs a user into their Microsoft account.
class MicrosoftAuthProvider extends AuthProvider {
  final Client httpClient;
  final Function(String) openUrl;

  MicrosoftAuthProvider({required this.httpClient, required this.openUrl});

  @override
  Future<void> login(
      BuildContext? context,
      String? username,
      String? password,
      Function(Account) callback,
      Function(String) error,
      Client? client) async {
    // ^ So here, we can't actually pass the client to [continueLogin],
    // where we actually need it, without modifications to [AuthProvider].
    // Therefore, we are using the provided [httpClient] instead and [null]
    // should be used for this parameter.
    if (context == null) {
      error('Build context must not be null.');
      return;
    }

    MicrosoftDialog.display(
        context, openUrl, (link) async => continueLogin(link, callback, error));
  }

  /// Continue logging in after the user provides a link.
  Future<void> continueLogin(
      String link, Function(Account) callback, Function(String) error) async {
    Uri uri;
    try {
      uri = Uri.parse(link);
    } catch (e) {
      error(e.toString());
      return;
    }

    Map<String, String> params = uri.queryParameters;
    if (!params.containsKey('code')) {
      // Should be impossible, cause [MicrosoftDialog] should have validated
      // the link to see if a code is present.
      error('Authentication code not present in the link provided.');
      return;
    }

    try {
      final MicrosoftAccount account = MicrosoftAccount();
      await requestMSTokens(params['code']!, account);
      await requestXboxLiveTokens(account);
      await requestXSTSTokens(account);
      await account.requestMinecraftToken(httpClient, error);
      await account.requestProfile(error, httpClient);
      callback(account);
    } catch (e) {
      error(e.toString());
    }
  }

  /// Get Microsoft access token/refresh token with OAuth2 auth code.
  Future<void> requestMSTokens(String code, MicrosoftAccount account) async {
    Response rToken = await httpClient.post(
        Uri.parse('https://login.live.com/oauth20_token.srf'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
            '&code=$code'
            '&grant_type=authorization_code'
            '&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf');

    if (rToken.statusCode != 200) {
      throw 'Microsoft returned non-200 status code. Code: ${rToken.statusCode}, body: ${rToken.body}';
    }

    Map<String, dynamic> msBody = jsonDecode(rToken.body);
    account.msAccessToken = msBody['access_token'];
    account.refreshToken = msBody['refresh_token'];
  }

  /// Authenticate with Xbox Live.
  Future<void> requestXboxLiveTokens(MicrosoftAccount account) async {
    Response rXBL = await httpClient.post(
        Uri.parse('https://user.auth.xboxlive.com/user/authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: jsonEncode({
          'Properties': {
            'AuthMethod': 'RPS',
            'SiteName': 'user.auth.xboxlive.com',
            'RpsTicket': '${account.msAccessToken}'
          },
          'RelyingParty': 'http://auth.xboxlive.com',
          'TokenType': 'JWT'
        }));

    if (rXBL.statusCode != 200) {
      throw 'Xbox Live returned a status code (${rXBL.statusCode}) that indicates failure.';
    }

    Map<String, dynamic> xblBody = jsonDecode(rXBL.body);
    account.xblToken = xblBody['Token'];
    account.xblUHS = xblBody['DisplayClaims']['xui'][0]['uhs'];
  }

  /// Authenticate with XSTS (What is this? I've never heard about this.)
  Future<void> requestXSTSTokens(MicrosoftAccount account) async {
    Response rXSTS = await httpClient.post(
        Uri.parse('https://xsts.auth.xboxlive.com/xsts/authorize'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: jsonEncode({
          'Properties': {
            'SandboxId': 'RETAIL',
            'UserTokens': [account.xblToken]
          },
          'RelyingParty': 'rp://api.minecraftservices.com/',
          'TokenType': 'JWT'
        }));

    if (rXSTS.statusCode == 401) {
      Map<String, dynamic> xstsBody = jsonDecode(rXSTS.body);
      if (xstsBody['XErr'] == 2148916233) {
        throw 'You don\'t have an Xbox Live account (separate from Microsoft account).';
      } else if (xstsBody['XErr'] == 2148916238) {
        // Should never happen with Minecraft's client ID.
        throw 'Your account is a children account, and must be added into a family.';
      }
      throw 'XSTS returned non-200 status code. Code: ${rXSTS.statusCode}, body: ${rXSTS.body}.';
    }

    Map<String, dynamic> xstsBody = jsonDecode(rXSTS.body);
    account.xstsToken = xstsBody['Token'];
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
