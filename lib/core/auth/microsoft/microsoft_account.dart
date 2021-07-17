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

import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';

/// MicrosoftAccount represents a Minecraft account using the Microsoft
/// account authentication system.
///
/// This is not tested, as I do not have a Microsoft account owning
/// Minecraft.
class MicrosoftAccount extends Account {
  /// Create an instance of [MicrosoftAccount] from a saved JSON state.
  static final Function(Map<String, dynamic>) fromJson =
      (Map<String, dynamic> json) {
    MicrosoftAccount account = MicrosoftAccount();
    account.accessToken = json['accessToken'];
    account.msAccessToken = json['msAccessToken'];
    account.refreshToken = json['refreshToken'];
    account.xblToken = json['xblToken'];
    account.xblUHS = json['xblUHS'];
    account.xstsToken = json['xstsToken'];
    account._profileName = json['profileName'];
    account._uuid = json['uuid'];
    account._requiresReauth = json['requiresReauth'];
    account.selected = json['selected'];
    return account;
  };

  static const CLIENT_ID = '00000000402b5328';
  static const REDIRECT_URI = 'https://login.live.com/oauth20_desktop.srf';

  late String accessToken; // Minecraft access token
  late String msAccessToken; // Microsoft access token
  late String refreshToken; // Microsoft refresh token
  late String xblToken; // Xbox Live token
  late String xblUHS; // Xbox Live user hash
  late String xstsToken; // XSTS token
  late String _profileName;
  late String _uuid;
  late bool selected = false;
  late bool _paid = false;

  // This happens when the user manually revokes the
  // access token.
  bool _requiresReauth = false;

  @override
  String get profileName => _profileName;

  @override
  Future<void> refresh(Client client) async {
    // Send a request to MS's token refresh server.
    Response resp =
        await client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'lilay-minecraft-launcher'
            },
            body: 'client_id=$CLIENT_ID'
                '&refresh_token=$refreshToken'
                '&grant_type=refresh_token'
                '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth');

    if (resp.statusCode != 200) {
      throw 'Microsoft returned non-200 code from token refresh request.';
    }

    Map<String, dynamic> respJson = jsonDecode(resp.body);
    msAccessToken = respJson['access_token'];
    refreshToken = respJson['refresh_token'];
  }

  @override
  Future<void> updatePaymentStatus(Client client) async {
    Response respPaid = await client.get(
        Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher',
          'Authorization': 'Bearer $accessToken'
        });

    if (respPaid.statusCode != 200) {
      return;
    }

    Map<String, dynamic> respPaidJson = jsonDecode(respPaid.body);
    for (Map<String, dynamic> product in respPaidJson['items']) {
      if (product['name'] == 'product_minecraft' ||
          product['name'] == 'game_minecraft') {
        _paid = true;
      }
    }
  }

  @override
  bool get requiresReauth => _requiresReauth;

  @override
  String get type => 'microsoft';

  @override
  String get username => 'nevergonnagiveyouup'; // Impossible to get

  @override
  String get uuid => _uuid;

  /// Request a Minecraft access token from Minecraft Xbox services.
  Future<void> requestMinecraftToken(
      Client client, Function(String) error) async {
    try {
      Response resp = await client.post(
          Uri.parse(
              'https://api.minecraftservices.com/authentication/login_with_xbox'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({'identityToken': 'XBL3.0 x=$xblUHS;$xstsToken'}));

      if (resp.statusCode != 200) {
        error('Minecraft authentication failed.');
        return;
      }

      Map<String, dynamic> respJson = jsonDecode(resp.body);
      accessToken = respJson['access_token'];
    } catch (e) {
      error(e.toString());
      return;
    }
  }

  Future<void> requestProfile(Function(String) error, Client client) async {
    try {
      Response resp = await client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $accessToken'
          });

      if (resp.statusCode != 200) {
        error('This Microsoft account does not own Minecraft.');
        return;
      }

      Map<String, dynamic> respJson = jsonDecode(resp.body);
      _profileName = respJson['name'];
      _uuid = respJson['id'];
    } catch (e) {
      error(e.toString());
      return;
    }
  }

  /// Manually convert this class to JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'msAccessToken': msAccessToken,
      'refreshToken': refreshToken,
      'xblToken': xblToken,
      'xstsToken': xstsToken,
      'xblUHS': xblUHS,
      'profileName': profileName,
      'type': type,
      'uuid': uuid,
      'requiresReauth': requiresReauth,
      'selected': selected
    };
  }

  @override
  bool get paid => _paid;

  @override
  Future<void> invalidate(Client client) async {
    // Can't find API endpoint for invalidating a token.
  }
}
