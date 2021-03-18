import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/yggdrasil/yggdrasil_account.dart';

class YggdrasilAuthProvider extends AuthProvider {
  @override
  Future<Account> login(String username, String? password) async {
    assert(password != null);

    // TODO Use the saved accessToken whenever possible, create a full configuration system for this

    Response response = await post(
        Uri.parse('https://authserver.mojang.com/authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'lilay-minecraft-launcher'
        },
        body: {
          'agent': {'name': 'Minecraft', 'version': 1},
          'username': username,
          'password': password,
          'requestUser': true
        });
    Map<String, dynamic> resp = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw resp['errorMessage'];
    }

    return YggdrasilAccount(jsonValue: resp);
  }

  @override
  bool requiresPassword() {
    return true;
  }
}
