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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'microsoft_auth_provider_test.mocks.dart';

const String MS_AUTH_CODE = 'lilaytest';
const String MS_ACCESS_TOKEN = 'lilaytest';
const String MS_REFRESH_TOKEN = 'lilaytest';
const String XBOX_LIVE_TOKEN = 'lilaytest';
const String XBOX_LIVE_UHS = 'lilaytest';
const String XSTS_TOKEN = 'lilaytest';
const String MINECRAFT_TOKEN = 'lilaytest';
const String PROFILE_NAME = 'Dreta';
const String MINECRAFT_UUID = '6cc9ba8e88034534a3d2ade79263cb1e';

@GenerateMocks([Client, MicrosoftAccount])
void main() {
  group('MicrosoftAuthProvider', () {
    test('Login fails if build context is null.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      bool errored = false;
      await auth.login(
          null,
          null,
          null,
          (account) => fail('Expected no result, but received $account.'),
          (error) => errored = true,
          null);
      expect(errored, true);
    });

    test('Correctly receives Microsoft access token and refresh token.',
        () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();

      mockMSTokensRequest(client, 200);

      await auth.requestMSTokens(MS_AUTH_CODE, account);
      expect(account.msAccessToken, MS_ACCESS_TOKEN);
      expect(account.refreshToken, MS_REFRESH_TOKEN);
    });

    test('Errors if Microsoft tokens request returns non-200 code.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();

      mockMSTokensRequest(client, 418);

      bool errored = false;
      try {
        await auth.requestMSTokens(MS_AUTH_CODE, account);
      } catch (_) {
        errored = true;
      }
      expect(errored, true);
    });

    test('Correctly receives Xbox Live token and user hash.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();
      account.msAccessToken = MS_ACCESS_TOKEN;

      mockXboxLiveTokensRequest(client, 200);

      await auth.requestXboxLiveTokens(account);
      expect(account.xblToken, XBOX_LIVE_TOKEN);
      expect(account.xblUHS, XBOX_LIVE_UHS);
    });

    test('Errors if Xbox Live authentication request returns non-200 code.',
        () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();

      mockXboxLiveTokensRequest(client, 401);

      bool errored = false;
      try {
        await auth.requestXboxLiveTokens(account);
      } catch (_) {
        errored = true;
      }
      expect(errored, true);
    });

    test('Correctly receives XSTS token.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();
      account.xblToken = XBOX_LIVE_TOKEN;

      mockXSTSTokenRequest(client, 200, null);

      await auth.requestXSTSToken(account);
      expect(account.xstsToken, XSTS_TOKEN);
    });

    test('Errors if XSTS token request returns non-200 code.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});
      final MicrosoftAccount account = MicrosoftAccount();

      mockXSTSTokenRequest(client, 401, XSTSErrorType.noAccount);

      bool errored = false;
      try {
        await auth.requestXSTSToken(account);
      } catch (_) {
        errored = true;
      }
      expect(errored, true);
    });

    test('Continue login correctly receives Minecraft profile and token.',
        () async {
      final MockClient client = MockClient();
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(httpClient: client, openUrl: (_) {});

      mockMSTokensRequest(client, 200);
      mockXboxLiveTokensRequest(client, 200);
      mockXSTSTokenRequest(client, 200, null);
      mockMinecraftTokenRequest(client, 200);
      mockProfileRequest(client, 200);

      await auth.continueLogin(
          'https://login.live.com/oauth20_desktop.srf?code=$MS_AUTH_CODE',
          (account) {
        expect(account.accessToken, MINECRAFT_TOKEN);
        expect(account.profileName, PROFILE_NAME);
        expect(account.uuid, MINECRAFT_UUID);
      }, (error) => fail('Expected no errors, but received $error.'));
    });
  });
}

void mockMSTokensRequest(Client client, int code) {
  when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
          headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null ||
        headers['Content-Type'] != 'application/x-www-form-urlencoded') {
      fail('Incorrect headers passed to Microsoft token request API.');
    }

    String? bodyRaw = invocation.namedArguments[Symbol('body')];
    if (bodyRaw == null) {
      fail('No body passed to Microsoft token request API.');
    }
    Map<String, String> body = Uri.splitQueryString(bodyRaw);
    if (body['client_id'] != MicrosoftAccount.CLIENT_ID ||
        body['code'] != MS_AUTH_CODE ||
        body['grant_type'] != 'authorization_code' ||
        body['redirect_uri'] != MicrosoftAccount.REDIRECT_URI) {
      fail('Incorrect body passed to Microsoft token request API.');
    }

    return Response(
        code == 200
            ? jsonEncode({
                'token_type': 'Bearer',
                'expires_in': 86400,
                'scope': 'service::user.auth.xboxlive.com::MBI_SSL',
                'access_token': MS_ACCESS_TOKEN,
                'refresh_token': MS_REFRESH_TOKEN,
                'user_id': '889ed4a3d844f672',
                'foci': '1'
              })
            : '',
        code);
  });
}

void mockXboxLiveTokensRequest(Client client, int code) {
  when(client.post(
          Uri.parse('https://user.auth.xboxlive.com/user/authenticate'),
          headers: anyNamed('headers'),
          body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null || headers['Content-Type'] != 'application/json') {
      fail('Incorrect headers passed to Xbox Live authentication API.');
    }

    String? bodyRaw = invocation.namedArguments[Symbol('body')];
    if (bodyRaw == null) {
      fail('No body passed to Xbox Live authentication API.');
    }

    Map<String, dynamic> body = jsonDecode(bodyRaw);
    if (body['RelyingParty'] != 'http://auth.xboxlive.com' ||
        body['TokenType'] != 'JWT' ||
        body['Properties']?['AuthMethod'] != 'RPS' ||
        body['Properties']?['SiteName'] != 'user.auth.xboxlive.com' ||
        body['Properties']?['RpsTicket'] != MS_ACCESS_TOKEN) {
      fail('Incorrect body passed to Xbox Live authentication API.');
    }

    return Response(
        code == 200
            ? jsonEncode({
                'IssueInstant': '2020-12-07T19:52:08.4463796Z',
                'NotAfter': '2020-12-07T19:52:08.4463796Z',
                'Token': XBOX_LIVE_TOKEN,
                'DisplayClaims': {
                  'xui': [
                    {'uhs': XBOX_LIVE_UHS}
                  ]
                }
              })
            : '',
        code);
  });
}

void mockXSTSTokenRequest(Client client, int code, XSTSErrorType? error) {
  when(client.post(Uri.parse('https://xsts.auth.xboxlive.com/xsts/authorize'),
          headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null || headers['Content-Type'] != 'application/json') {
      fail('Incorrect headers passed to XSTS authorization API.');
    }

    String? bodyRaw = invocation.namedArguments[Symbol('body')];
    if (bodyRaw == null) {
      fail('No body passed to XSTS authorization API.');
    }

    Map<String, dynamic> body = jsonDecode(bodyRaw);
    if (body['RelyingParty'] != 'rp://api.minecraftservices.com/' ||
        body['TokenType'] != 'JWT' ||
        body['Properties']?['SandboxId'] != 'RETAIL' ||
        body['Properties']?['UserTokens']?[0] != XBOX_LIVE_TOKEN) {
      fail('Incorrect body passed to XSTS authorization API.');
    }

    String resp = '';
    if (code == 200) {
      resp = jsonEncode({
        'IssueInstant': '2020-12-07T19:52:09.2345095Z',
        'NotAfter': '2020-12-07T19:52:09.2345095Z',
        'Token': XSTS_TOKEN,
        'DisplayClaims': {
          'xui': [
            {'uhs': XBOX_LIVE_UHS}
          ]
        }
      });
    } else if (error == XSTSErrorType.noAccount) {
      resp = jsonEncode({
        'Identity': '0',
        'XErr': 2148916233,
        'Message': 'This account doesn\'t have an Xbox account.',
        'Redirect': 'https://account.xbox.com/en-us/accountcreation'
      });
    } else if (error == XSTSErrorType.isChildren) {
      resp = jsonEncode({
        'Identity': '0',
        'XErr': 2148916238,
        'Message':
            'This account is a child and cannot proceed unless the account is added to a family by an adult.',
        'Redirect': 'https://start.ui.xboxlive.com/AddChildToFamily'
      });
    }

    return Response(resp, code);
  });
}

void mockProfileRequest(Client client, int code) {
  when(client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: anyNamed('headers')))
      .thenAnswer((invocation) async {
    if (invocation.namedArguments[Symbol('headers')]['Authorization'] !=
        'Bearer $MINECRAFT_TOKEN') {
      fail('Specified incorrect Authorization header when receiving profile.');
    }
    return Response(
        jsonEncode({'name': 'Dreta', 'id': '6cc9ba8e88034534a3d2ade79263cb1e'}),
        code);
  });
}

void mockMinecraftTokenRequest(Client client, int code) {
  when(client.post(
          Uri.parse(
              'https://api.minecraftservices.com/authentication/login_with_xbox'),
          headers: anyNamed('headers'),
          body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null || headers['Content-Type'] != 'application/json') {
      fail('Incorrect headers passed to Minecraft token API.');
    }

    String? bodyRaw = invocation.namedArguments[Symbol('body')];
    if (bodyRaw == null) {
      fail('No body passed to Minecraft token API.');
    }

    Map<String, dynamic> body = jsonDecode(bodyRaw);
    if (body['identityToken'] != 'XBL3.0 x=$XBOX_LIVE_UHS;$XSTS_TOKEN') {
      fail('Incorrect body passed to Minecraft token API.');
    }

    return Response(
        code == 200 ? jsonEncode({'access_token': 'lilaytest'}) : '', code);
  });
}

enum XSTSErrorType { noAccount, isChildren }
