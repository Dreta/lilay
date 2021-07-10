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
import 'package:lilay/core/auth/yggdrasil/yggdrasil_auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'yggdrasil_auth_provider_test.mocks.dart';

const String TOKEN = 'lilaytest';
const String PROFILE_NAME = 'Dreta';
const String USERNAME = 'olleh@dreta.dev';
const String PASSWORD = 'MostSecurePasswordEver';
const String UUID = '6cc9ba8e88034534a3d2ade79263cb1e';
const bool PAID = true;

@GenerateMocks([Client])
void main() {
  group('YggdrasilAuthProvider', () {
    test('Account access token correct after login.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      await auth.login(USERNAME, PASSWORD, (account) {
        expect(account.accessToken, TOKEN);
      }, (error) {
        fail('Expected no errors, but received $error.');
      }, client);
    });

    test('Account profile name correct after login.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      await auth.login(USERNAME, PASSWORD, (account) {
        expect(account.profileName, PROFILE_NAME);
      }, (error) {
        fail('Expected no errors, but received $error.');
      }, client);
    });

    test('Account username correct after login.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      await auth.login(USERNAME, PASSWORD, (account) {
        expect(account.username, USERNAME);
      }, (error) {
        fail('Expected no errors, but received $error.');
      }, client);
    });

    test('Account UUID correct after login.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      await auth.login(USERNAME, PASSWORD, (account) {
        expect(account.uuid.replaceAll('-', ''), UUID);
      }, (error) {
        fail('Expected no errors, but received $error.');
      }, client);
    });

    test('Account payment status correct after login.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 418);

      await auth.login(USERNAME, PASSWORD, (account) {
        expect(account.paid, false);
      }, (error) {
        fail('Expected no errors, but received $error.');
      }, client);
    });

    test('Login fails if authenticate responds with non-200 code.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 403);
      mockPaymentCheck(client, 200);

      bool errored = false;
      await auth.login(USERNAME, PASSWORD, (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, client);
      expect(errored, true);
    });

    test('Login fails if username is null.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      bool errored = false;
      await auth.login(null, PASSWORD, (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, client);
      expect(errored, true);
    });

    test('Login fails if password is null.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      bool errored = false;
      await auth.login(USERNAME, null, (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, client);
      expect(errored, true);
    });

    test('Login fails if username is wrong.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      bool errored = false;
      await auth.login('wrongusername@example.org', PASSWORD, (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, client);
      expect(errored, true);
    });

    test('Login fails if password is wrong.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();
      final MockClient client = MockClient();

      mockAuthenticate(client, 200);
      mockPaymentCheck(client, 200);

      bool errored = false;
      await auth.login(USERNAME, 'wrongpassword123', (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, client);
      expect(errored, true);
    });

    test('Login fails if client is null.', () async {
      final YggdrasilAuthProvider auth = YggdrasilAuthProvider();

      bool errored = false;
      await auth.login(USERNAME, PASSWORD, (account) {
        fail('Expected no result, but received $account.');
      }, (error) {
        errored = true;
      }, null);
      expect(errored, true);
    });
  });
}

void mockAuthenticate(Client client, int code) {
  when(client.post(Uri.parse('https://authserver.mojang.com/authenticate'),
          headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null || headers['Content-Type'] != 'application/json') {
      fail('Incorrect headers passed to Yggdrasil authenticate API.');
    }

    String? bodyRaw = invocation.namedArguments[Symbol('body')];
    if (bodyRaw == null) {
      fail('No body passed to Yggdrasil authenticate API.');
    }
    Map<String, dynamic> body = jsonDecode(bodyRaw);
    if (body['agent'] == null ||
        body['agent']['name'] != 'Minecraft' ||
        body['agent']['version'] != 1) {
      fail('Incorrect body agent passed to Yggdrasil authenticate API.');
    }

    if (body['username'] != USERNAME || body['password'] != PASSWORD) {
      return Response(
          jsonEncode({
            'error': 'ForbiddenOperationException',
            'errorMessage': 'Invalid credentials. Invalid username or password.'
          }),
          403);
    }

    return Response(
        jsonEncode({
          'accessToken': TOKEN,
          'selectedProfile': {'id': UUID, 'name': PROFILE_NAME},
          'user': (body['requestUser'] ?? false)
              ? {
                  'username': USERNAME,
                  'properties': [
                    {'name': 'preferredLanguage', 'value': 'en'}
                  ]
                }
              : null
        }),
        code);
  });
}

void mockPaymentCheck(Client client, int code) {
  when(client.get(
          Uri.parse(
              'https://api.mojang.com/users/profiles/minecraft/$PROFILE_NAME'),
          headers: anyNamed('headers')))
      .thenAnswer((invocation) async {
    Map<String, String>? headers = invocation.namedArguments[Symbol('headers')];
    if (headers == null) {
      fail('Incorrect headers passed to Mojang user profile API.');
    }
    return Response(
        code == 200
            ? jsonEncode({'name': PROFILE_NAME, 'id': UUID.replaceAll('-', '')})
            : '',
        code);
  });
}
