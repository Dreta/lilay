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
  // TODO Do not use the direct JSON value - extract separate values instead.
  final Map<String, dynamic> jsonValue;

  // This happens when the user manually revokes the
  // access token.
  bool _requiresReauth = false;

  YggdrasilAccount({required this.jsonValue});

  @override
  String get accessToken => jsonValue['accessToken'];

  @override
  String get profileName => jsonValue['selectedProfile']['name'];

  @override
  String get username => jsonValue['user']['username'];

  @override
  String get uuid => dashifyUUID(jsonValue['selectedProfile']['id']);

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
      jsonValue['accessToken'] = resp['accessToken'];
      jsonValue['user']['username'] = resp['user']['username'];
      jsonValue['selectedProfile']['name'] = resp['selectedProfile']['name'];
    }
  }

  @override
  bool get requiresReauth => _requiresReauth;
}
