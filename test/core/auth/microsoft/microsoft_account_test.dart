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

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode(
              {'name': 'Dreta', 'id': '6cc9ba8e88034534a3d2ade79263cb1e'}),
          200));

      await account.requestProfile(
          (err) => fail('Expected no errors, but received $err.'), client);
      expect(account.profileName, 'Dreta');
    });

    test('Profile ID should be received when available.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode(
              {'name': 'Dreta', 'id': '6cc9ba8e88034534a3d2ade79263cb1e'}),
          200));

      await account.requestProfile(
          (err) => fail('Expected no errors, but received $err.'), client);
      expect(account.uuid, '6cc9ba8e88034534a3d2ade79263cb1e');
    });

    test('Profile shouldn\'t be received when the status code isn\'t 200.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/minecraft/profile'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode(
              {'name': 'Dreta', 'id': '6cc9ba8e88034534a3d2ade79263cb1e'}),
          418));

      bool errored = false;
      await account.requestProfile((err) => errored = true, client);
      expect(errored, true);
    });

    test('Refresh should set the correct Microsoft access token.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
                  '&refresh_token=lilaytest'
                  '&grant_type=refresh_token'
                  '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'))
          .thenAnswer((_) async => Response(
              jsonEncode({
                'access_token': 'lilaytest2',
                'refresh_token': 'lilaytest2'
              }),
              200));

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode({
            'items': [
              {'name': 'product_minecraft', 'signature': 'lilaytest'},
              {'name': 'game_minecraft', 'signature': 'lilaytest'}
            ],
            'signature': 'lilaytest',
            'keyId': 1
          }),
          200));

      await account.refresh(client);
      expect(account.msAccessToken, 'lilaytest2');
    });

    test('Refresh should set the correct Microsoft refresh token.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
                  '&refresh_token=lilaytest'
                  '&grant_type=refresh_token'
                  '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'))
          .thenAnswer((_) async => Response(
              jsonEncode({
                'access_token': 'lilaytest3',
                'refresh_token': 'lilaytest3'
              }),
              200));

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode({
            'items': [
              {'name': 'product_minecraft', 'signature': 'lilaytest'},
              {'name': 'game_minecraft', 'signature': 'lilaytest'}
            ],
            'signature': 'lilaytest',
            'keyId': 1
          }),
          200));

      await account.refresh(client);
      expect(account.refreshToken, 'lilaytest3');
    });

    test('Refresh should set the correct payment status.', () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
                  '&refresh_token=lilaytest'
                  '&grant_type=refresh_token'
                  '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'))
          .thenAnswer((_) async => Response(
              jsonEncode({
                'access_token': 'lilaytest3',
                'refresh_token': 'lilaytest3'
              }),
              200));

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode({
            'items': [
              {'name': 'product_minecraft', 'signature': 'lilaytest'},
              {'name': 'game_minecraft', 'signature': 'lilaytest'}
            ],
            'signature': 'lilaytest',
            'keyId': 1
          }),
          200));

      await account.refresh(client);
      expect(account.paid, true);
    });

    test('Refresh should fail if refresh request returns a non-200 code.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
                  '&refresh_token=lilaytest'
                  '&grant_type=refresh_token'
                  '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'))
          .thenAnswer((_) async => Response(
              jsonEncode({
                'access_token': 'lilaytest3',
                'refresh_token': 'lilaytest3'
              }),
              418));

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode({
            'items': [
              {'name': 'product_minecraft', 'signature': 'lilaytest'},
              {'name': 'game_minecraft', 'signature': 'lilaytest'}
            ],
            'signature': 'lilaytest',
            'keyId': 1
          }),
          200));

      bool errored = false;
      try {
        await account.refresh(client);
      } catch (_) {
        errored = true;
      }

      expect(errored, true);
    });

    test(
        'Refresh should set payment status to false if the request returns a non-200 code.',
        () async {
      final MicrosoftAccount account = MicrosoftAccount();
      final Client client = MockClient();
      account.accessToken = 'lilaytest';
      account.refreshToken = 'lilaytest';

      when(client.post(Uri.parse('https://login.live.com/oauth20_token.srf'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: 'client_id=${MicrosoftAccount.CLIENT_ID}'
                  '&refresh_token=lilaytest'
                  '&grant_type=refresh_token'
                  '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'))
          .thenAnswer((_) async => Response(
              jsonEncode({
                'access_token': 'lilaytest3',
                'refresh_token': 'lilaytest3'
              }),
              200));

      when(client.get(
          Uri.parse('https://api.minecraftservices.com/entitlements/mcstore'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer lilaytest'
          })).thenAnswer((_) async => Response(
          jsonEncode({
            'items': [
              {'name': 'product_minecraft', 'signature': 'lilaytest'},
              {'name': 'game_minecraft', 'signature': 'lilaytest'}
            ],
            'signature': 'lilaytest',
            'keyId': 1
          }),
          418));

      await account.refresh(client);
      expect(account.paid, false);
    });
  });
}
