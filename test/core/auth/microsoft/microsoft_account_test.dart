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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'microsoft_account_test.mocks.dart';

@GenerateMocks([Client])
void main() {
  group('MicrosoftAccount', () {
    test('Profile name should be received when available.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      mockProfileRequest(client, 200);

      await account.requestProfile(
          (err) => fail('Expected no errors, but received $err.'), client);
      expect(account.profileName, 'Dreta');
    });

    test('Profile ID should be received when available.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      mockProfileRequest(client, 200);

      await account.requestProfile(
          (err) => fail('Expected no errors, but received $err.'), client);
      expect(account.uuid, '6cc9ba8e88034534a3d2ade79263cb1e');
    });

    test('Profile shouldn\'t be received when the status code isn\'t 200.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      mockProfileRequest(client, 418);

      bool errored = false;
      await account.requestProfile((err) => errored = true, client);
      expect(errored, true);
    });

    test('Refresh should set the correct Microsoft access token.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      mockMSOAuth2(client, 200);

      await account.refresh(client);
      expect(account.msAccessToken, 'lilaytest');
    });

    test('Refresh should set the correct Microsoft refresh token.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      mockMSOAuth2(client, 200);

      await account.refresh(client);
      expect(account.refreshToken, 'lilaytest');
    });

    test('Update payment status should set the correct payment status.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      mockEntitlements(client, 200);

      await account.updatePaymentStatus(client);
      expect(account.paid, true);
    });

    test('Refresh should fail if refresh request returns a non-200 code.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      mockMSOAuth2(client, 418);

      bool errored = false;
      try {
        await account.refresh(client);
      } catch (_) {
        errored = true;
      }

      expect(errored, true);
    });

    test(
        'Update payment status should set payment status to false if the request returns a non-200 code.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      mockEntitlements(client, 418);

      await account.updatePaymentStatus(client);
      expect(account.paid, false);
    });
  });
}

void mockProfileRequest(Client client, int code) {
  when(client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: anyNamed('headers')))
      .thenAnswer((invocation) async {
    if (invocation.namedArguments[Symbol('headers')]['Authorization'] !=
        'Bearer lilaytest') {
      fail('Specified incorrect Authorization header when receiving profile.');
    }
    return Response(
        jsonEncode({'name': 'Dreta', 'id': '6cc9ba8e88034534a3d2ade79263cb1e'}),
        code);
  });
}

void mockMSOAuth2(Client client, int code) {
  when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
          headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null ||
        headers['Content-Type'] != 'application/x-www-form-urlencoded') {
      fail('Incorrect headers passed to Microsoft OAuth2 authorization API.');
    }

    Map<String, String> parameters = Uri.splitQueryString(
        invocation.namedArguments[Symbol('body')].toString());
    if (parameters['client_id'] != MicrosoftAccount.CLIENT_ID ||
        parameters['refresh_token'] != 'lilaytest' ||
        parameters['grant_type'] != 'refresh_token' ||
        parameters['redirect_uri'] != 'http://localhost:35129/msauth') {
      fail('Incorrect arguments passed to Microsoft OAuth2 authorization API.');
    }

    return Response(
        jsonEncode({'access_token': 'lilaytest', 'refresh_token': 'lilaytest'}),
        code);
  });
}

void mockEntitlements(Client client, int code) {
  when(client.get(
      Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'lilay-minecraft-launcher',
        'Authorization': 'Bearer lilaytest'
      })).thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null ||
        headers['Content-Type'] != 'application/json' ||
        headers['Authorization'] != 'Bearer lilaytest') {
      fail('Incorrect headers passed to Minecraft Services entitlements API.');
    }

    return Response(
        jsonEncode({
          'items': [
            {'name': 'product_minecraft', 'signature': 'lilaytest'},
            {'name': 'game_minecraft', 'signature': 'lilaytest'}
          ],
          'signature': 'lilaytest',
          'keyId': 1
        }),
        code);
  });
}
