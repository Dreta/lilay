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
    account.xblUHS = json['xblUHS'];
    account.xstsToken = json['xstsToken'];
    account._profileName = json['profileName'];
    account._uuid = json['uuid'];
    account._requiresReauth = json['requiresReauth'];
    account.selected = json['selected'];
    return account;
  };

  static const CLIENT_ID = '';
  static const CLIENT_SECRET = '';

  late String accessToken; // Minecraft access token
  late String msAccessToken; // Microsoft access token
  late String refreshToken; // Microsoft refresh token
  late String xblUHS; // Xbox Live UHS (what is this?)
  late String xstsToken; // XSTS token
  late String _profileName;
  late String _uuid;
  late bool selected = false;

  // This happens when the user manually revokes the
  // access token.
  bool _requiresReauth = false;

  @override
  String get profileName => _profileName;

  @override
  Future<void> refresh() async {
    // Send a request to MS's token refresh server.
    Response resp =
        await post(Uri.parse('https://login.live.com/oauth20_token.srf'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'lilay-minecraft-launcher'
            },
            body: 'client_id=$CLIENT_ID'
                '&client_secret=$CLIENT_SECRET'
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
  bool get requiresReauth => _requiresReauth;

  @override
  String get type => 'microsoft';

  @override
  String get username => 'nevergonnagiveyouup'; // Impossible to get

  @override
  String get uuid => _uuid;

  /// Request a Minecraft access token from Minecraft Xbox services.
  void requestMinecraftToken() async {
    Response resp = await post(
        Uri.parse(
            'https://api.minecraftservices.com/authentication/login_with_xbox'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: {
          'identityToken': 'XBL3.0 x=$xblUHS;$xstsToken'
        });

    if (resp.statusCode != 200) {
      throw 'Minecraft authentication failed.';
    }

    Map<String, dynamic> respJson = jsonDecode(resp.body);
    accessToken = respJson['access_token'];
  }

  /// Manually convert this class to JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'msAccessToken': msAccessToken,
      'refreshToken': refreshToken,
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
  Future<bool> paid() async {
    Response resp = await get(
        Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher',
          'Authorization': 'Bearer $accessToken'
        });

    if (resp.statusCode != 200) {
      return true;
    }

    Map<String, dynamic> respJson = jsonDecode(resp.body);
    for (Map<String, dynamic> product in respJson['items']) {
      if (product['name'] == 'product_minecraft' ||
          product['name'] == 'game_minecraft') {
        return true;
      }
    }
    return false;
  }
}
