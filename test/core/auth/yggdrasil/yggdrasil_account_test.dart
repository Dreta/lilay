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
import 'package:lilay/core/auth/yggdrasil/yggdrasil_account.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'yggdrasil_account_test.mocks.dart';

const String TOKEN = 'lilaytest';
const String NEW_TOKEN = 'lilaytestnew';
const String PROFILE_NAME = 'Dreta';
const String NEW_NAME = 'Aberdeener';
const String USERNAME = 'olleh@dreta.dev';
const String NEW_USERNAME = 'aberdeener@dreta.dev';
const String UUID = '6cc9ba8e-8803-4534-a3d2-ade79263cb1e';
const bool PAID = true;

@GenerateMocks([Client])
void main() {
  group('YggdrasilAccount', () {
    test(
        'Refresh should set the access token correctly when the token is unusable.',
        () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 403));

      when(client.post(Uri.parse('https://authserver.mojang.com/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({
            'accessToken': TOKEN,
            'requestUser': true
            // We also want to update the user just in case
          }))).thenAnswer((_) async => Response(
          jsonEncode({
            'accessToken': NEW_TOKEN,
            'selectedProfile': {'id': UUID, 'name': NEW_NAME},
            'user': {'username': NEW_USERNAME}
          }),
          200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$NEW_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $NEW_TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.accessToken, NEW_TOKEN);
    });
    test(
        'Refresh should set the username correctly when the token is unusable.',
        () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 403));

      when(client.post(Uri.parse('https://authserver.mojang.com/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({
            'accessToken': TOKEN,
            'requestUser': true
            // We also want to update the user just in case
          }))).thenAnswer((_) async => Response(
          jsonEncode({
            'accessToken': NEW_TOKEN,
            'selectedProfile': {'id': UUID, 'name': NEW_NAME},
            'user': {'username': NEW_USERNAME}
          }),
          200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$NEW_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $NEW_TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.username, NEW_USERNAME);
    });
    test(
        'Refresh should set the profile name correctly when the token is unusable.',
        () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 403));

      when(client.post(Uri.parse('https://authserver.mojang.com/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({
            'accessToken': TOKEN,
            'requestUser': true
            // We also want to update the user just in case
          }))).thenAnswer((_) async => Response(
          jsonEncode({
            'accessToken': NEW_TOKEN,
            'selectedProfile': {'id': UUID, 'name': NEW_NAME},
            'user': {'username': NEW_USERNAME}
          }),
          200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$NEW_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $NEW_TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.profileName, NEW_NAME);
    });
    test(
        'Refresh should require re-authentication when the token can\'t be refreshed.',
        () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 403));

      when(client.post(Uri.parse('https://authserver.mojang.com/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({
            'accessToken': TOKEN,
            'requestUser': true
            // We also want to update the user just in case
          }))).thenAnswer((_) async => Response(jsonEncode({}), 418));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$NEW_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $NEW_TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.requiresReauth, true);
    });
    test('Refresh should use old token if it is still usable.', () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$PROFILE_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.accessToken, TOKEN);
    });
    test('Refresh should set the payment status correctly (true).', () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$PROFILE_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $TOKEN'
          })).thenAnswer((_) async => Response('', 200));

      await account.refresh(client);
      expect(account.paid, true);
    });
    test('Refresh should set the payment status correctly (false).', () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      when(client.post(Uri.parse('https://authserver.mojang.com/validate'),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'lilay-minecraft-launcher'
              },
              body: jsonEncode({'accessToken': TOKEN})))
          .thenAnswer(
              (_) async => Response(jsonEncode({'accessToken': TOKEN}), 200));

      when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$PROFILE_NAME'),
          headers: {
            'User-Agent': 'lilay-minecraft-launcher',
            'Authorization': 'Bearer $TOKEN'
          })).thenAnswer((_) async => Response('', 403));

      await account.refresh(client);
      expect(account.paid, false);
    });
    test('Invalidate token correctly.', () async {
      final YggdrasilAccount account = defaultAccount;
      final Client client = MockClient();

      bool called = false;
      when(client.post(Uri.parse('https://authserver.mojang.com/invalidate'),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'lilay-minecraft-launcher'
          },
          body: jsonEncode({'accessToken': TOKEN}))).thenAnswer((_) async {
        called = true;
        return Response('', 200);
      });

      await account.invalidate(client);
      expect(called, true);
    });
  });
}

YggdrasilAccount get defaultAccount {
  return YggdrasilAccount(
      accessToken: TOKEN,
      profileName: PROFILE_NAME,
      username: USERNAME,
      uuid: UUID,
      paid: PAID);
}
