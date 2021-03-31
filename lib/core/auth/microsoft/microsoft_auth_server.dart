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
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:logging/logging.dart';

/// This class listens on localhost: for a Microsoft authentication
/// response and acts accordingly.
class MicrosoftAuthServer {
  late Function(Account) accountCallback;
  late Function(String) errorCallback;
  late HttpServer _server;

  MicrosoftAuthServer(int port) {
    HttpServer.bind(InternetAddress.loopbackIPv4, port).then((server) {
      _server = server;
      _handle();
    });
    GetIt.I
        .get<Logger>()
        .info('Microsoft auth server listening on localhost:$port.');
  }

  _handle() async {
    await for (HttpRequest request in _server) {
      // If we are in /msauth
      // We are doing a simple check that won't be always accurate here,
      // but for our use case it's perfectly fine.
      if (request.requestedUri.pathSegments.contains('msauth')) {
        _handleRequest(request);
      }
    }
  }

  _handleRequest(HttpRequest request) async {
    try {
      // Get code from GET request
      String? code = request.uri.queryParameters['code'];
      if (code == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Invalid request, authentication code is missing.')
          ..close();
        return;
      }

      // Authentication code -> Authentication token
      Response rToken = await post(
          Uri.parse('https://login.live.com/oauth20_token.srf'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
              '&code=$code'
              '&grant_type=authorization_code'
              '&redirect_uri=http%3A%2F%2Flocalhost%3A${_server.port}%2Fmsauth');

      if (rToken.statusCode != 200) {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write(
              'Microsoft returned non-200 status code. Code: ${rToken.statusCode}, body: ${rToken.body}')
          ..close();
        return;
      }

      Map<String, dynamic> msBody = jsonDecode(rToken.body);
      MicrosoftAccount account = MicrosoftAccount();
      account.msAccessToken = msBody['access_token'];
      account.refreshToken = msBody['refresh_token'];

      // Authenticate with Xbox Live
      Response rXBL = await post(
          Uri.parse('https://user.auth.xboxlive.com/user/authenticate'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({
            'Properties': {
              'AuthMethod': 'RPS',
              'SiteName': 'user.auth.xboxlive.com',
              'RpsTicket': 'd=${account.msAccessToken}'
            },
            'RelyingParty': 'http://auth.xboxlive.com',
            'TokenType': 'JWT'
          }));

      if (rXBL.statusCode != 200) {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write(
              'Xbox Live returned non-200 status code. Code: ${rXBL.statusCode}, body: ${rXBL.body}')
          ..close();
        return;
      }

      Map<String, dynamic> xblBody = jsonDecode(rXBL.body);
      String xblToken = xblBody['Token'];
      account.xblUHS = xblBody['DisplayClaims']['xui'][0]['uhs'];

      // Authenticate with XSTS
      Response rXSTS =
          await post(Uri.parse('https://xsts.auth.xboxlive.com/xsts/authorize'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({
                'Properties': {
                  'SandboxId': 'RETAIL',
                  'UserTokens': [xblToken]
                },
                'RelyingParty': 'rp://api.minecraftservices.com/',
                'TokenType': 'JWT'
              }));

      if (rXSTS.statusCode == 401) {
        Map<String, dynamic> xstsBody = jsonDecode(rXSTS.body);
        if (xstsBody['XErr'] == 2148916233) {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write(
                'You don\'t have an Xbox account. Please create one before continuing.')
            ..close();
        } else if (xstsBody['XErr'] == 2148916238) {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write(
                'You are a minority and you cannot proceed unless the account is added to a family by an adult.')
            ..close();
        }
        return;
      }

      Map<String, dynamic> xstsBody = jsonDecode(rXSTS.body);
      account.xstsToken = xstsBody['Token'];

      // Authenticate with Minecraft
      await account.requestMinecraftToken(errorCallback);
      await account.requestProfile(errorCallback);
      accountCallback(account);

      request.response
        ..statusCode = HttpStatus.ok
        ..write('Authentication successful. You can return to Lilay now.')
        ..close();
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
