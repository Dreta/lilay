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
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
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
      } else if (request.requestedUri.pathSegments.contains('background.png')) {
        // If we are requesting the background image
        // This might look ugly, but I don't think it matters.
        _handleBackgroundRequest(request);
      }
    }
  }

  _handleBackgroundRequest(HttpRequest request) async {
    final ByteData background = await rootBundle.load('assets/background.png');

    request.response
      ..headers.contentType = ContentType('image', 'png')
      ..add(List.from(background.buffer
          .asUint8List(background.offsetInBytes, background.lengthInBytes)))
      ..close();
  }

  _handleRequest(HttpRequest request) async {
    try {
      // Get code from GET request
      String? code = request.uri.queryParameters['code'];
      if (code == null) {
        request.response
          ..headers.contentType = ContentType.html
          ..statusCode = HttpStatus.badRequest
          ..write((await rootBundle.loadString('assets/msauthfailed.html'))
              .replaceAll('{error}',
                  'Invalid request, authentication code is missing.'))
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
        // It might be better to use a proper HTML templating library,
        // but I believe that is too overkill.
        request.response
          ..headers.contentType = ContentType.html
          ..statusCode = HttpStatus.forbidden
          ..write((await rootBundle.loadString('assets/msauthfailed.html'))
              .replaceAll('{error}',
                  'Microsoft returned non-200 status code. Code: ${rToken.statusCode}, body: ${rToken.body}'))
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
          ..headers.contentType = ContentType.html
          ..statusCode = HttpStatus.forbidden
          ..write((await rootBundle.loadString('assets/msauthfailed.html'))
              .replaceAll('{error}',
                  'Xbox Live returned a status code (${rXBL.statusCode}) that indicates failure.'))
          ..close();
        errorCallback(
            'Xbox Live returned a status code (${rXBL.statusCode}) that indicates failure.');
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
            ..headers.contentType = ContentType.html
            ..statusCode = HttpStatus.forbidden
            ..write((await rootBundle.loadString('assets/msauthfailed.html'))
                .replaceAll('{error}',
                    'You don\'t have an Xbox Live account (which is separate from your Microsoft account). Please create one before continuing.'))
            ..close();
          errorCallback(
              'You don\'t have an Xbox Live account. Please create one before continuing.');
        } else if (xstsBody['XErr'] == 2148916238) {
          request.response
            ..headers.contentType = ContentType.html
            ..statusCode = HttpStatus.forbidden
            ..write((await rootBundle.loadString('assets/msauthfailed.html'))
                .replaceAll('{error}',
                    'You are a children and can not proceed unless this account is added to a family by an adult.'))
            ..close();
          errorCallback(
              'You are a children and can not proceed unless this account is added to a family by an adult.');
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
        ..headers.contentType = ContentType.html
        ..statusCode = HttpStatus.ok
        ..write(await rootBundle.loadString('assets/msauthsuccess.html'))
        ..close();
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
