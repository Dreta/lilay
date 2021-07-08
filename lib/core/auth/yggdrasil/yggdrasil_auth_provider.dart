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
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/yggdrasil/yggdrasil_account.dart';

/// YggdrasilAuthProvider logs a user into their Mojang account
/// with the provided username (email) and password.
class YggdrasilAuthProvider extends AuthProvider {
  @override
  void login(String? username, String? password, Function(Account) callback,
      Function(String) error, Client? client) {
    assert(username != null);
    assert(password != null);
    assert(client != null);

    client!
        .post(Uri.parse('https://authserver.mojang.com/authenticate'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'lilay-minecraft-launcher'
            },
            body: jsonEncode({
              'agent': {'name': 'Minecraft', 'version': 1},
              'username': username,
              'password': password,
              'requestUser': true
            }))
        .then((response) {
      Map<String, dynamic> resp = jsonDecode(response.body);
      if (response.statusCode != 200) {
        error('${resp['errorMessage']}');
        return;
      }

      // Check if the player paid
      client!.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/${resp['selectedProfile']['name']}'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher'
          }).then((respPaid) => callback(YggdrasilAccount(
          accessToken: resp['accessToken'],
          profileName: resp['selectedProfile']['name'],
          username: resp['user']['username'],
          uuid: resp['selectedProfile']['id'],
          paid: respPaid.statusCode == 200)));
    }).catchError((err) => error(err.toString()));
  }

  @override
  String get name => 'Mojang';

  @override
  String get type => 'yggdrasil';
}
