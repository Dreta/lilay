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
import 'package:lilay/utils.dart';

/// YggdrasilAccount represents a Minecraft account using the Mojang
/// account authentication system.
class YggdrasilAccount extends Account {
  /// Create an instance of [YggdrasilAccount] from a saved JSON state.
  static final Function(Map<String, dynamic>) fromJson =
      (Map<String, dynamic> json) {
    YggdrasilAccount account = YggdrasilAccount._();
    account._accessToken = json['accessToken'];
    account._profileName = json['profileName'];
    account._username = json['username'];
    account._uuid = json['uuid'];
    account._paid = json['paid'];
    account._requiresReauth = json['requiresReauth'];
    return account;
  };

  late String _accessToken;
  late String _profileName;
  late String _username;
  late String _uuid;
  late bool _paid;

  // This happens when the user manually revokes the
  // access token.
  bool _requiresReauth = false;

  YggdrasilAccount._();

  /// Create a [YggdrasilAccount] from a Mojang /authenticate
  /// response body.
  YggdrasilAccount({required Map<String, dynamic> json}) {
    _accessToken = json['accessToken'];
    _profileName = json['selectedProfile']['name'];
    _username = json['user']['username'];
    _paid = json['selectedProfile']['paid'];
    _uuid = dashifyUUID(json['selectedProfile']['id']);
  }

  @override
  String get accessToken => _accessToken;

  @override
  String get profileName => _profileName;

  @override
  String get username => _username;

  @override
  String get uuid => _uuid;

  @override
  Future<void> refresh() async {
    if (requiresReauth) {
      return;
    }

    Response rValidate = await post(
        Uri.parse('https://authserver.mojang.com/validate'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: {
          'accessToken': accessToken
        });
    if (rValidate.statusCode == 403) {
      // The token is unusable.
      Response rRefresh = await post(
          Uri.parse('https://authserver.mojang.com/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: {
            'accessToken': accessToken,
            'requestUser': true // We also want to update the user just in case
          });
      if (rRefresh.statusCode != 200) {
        _requiresReauth = true; // We can't refresh. Force re-authenticate.
        return;
      }

      // Update the access token and user info
      Map<String, dynamic> resp = jsonDecode(rRefresh.body);
      _accessToken = resp['accessToken'];
      _username = resp['user']['username'];
      _profileName = resp['selectedProfile']['name'];
      _paid = resp['selectedProfile']['paid'];
    }
  }

  @override
  bool get requiresReauth => _requiresReauth;

  @override
  String get type => 'yggdrasil';

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'accessToken': accessToken,
      'profileName': profileName,
      'paid': _paid,
      'type': type,
      'uuid': uuid,
      'requiresReauth': requiresReauth
    };
  }

  @override
  Future<bool> paid() async => _paid;
}
