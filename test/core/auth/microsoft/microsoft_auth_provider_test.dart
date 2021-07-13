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

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_provider.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_server.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';

import 'microsoft_auth_provider_test.mocks.dart';

@GenerateMocks([Client, Account])
void main() {
  group('MicrosoftAuthProvider', () {
    GetIt.I.registerSingleton<Logger>(Logger('MicrosoftAuthProvider Test'));

    test('Login opens OAuth2 URL with correct parameters.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthServer server = MicrosoftAuthServer(35129, client);

      bool opened = false;
      final MicrosoftAuthProvider auth = MicrosoftAuthProvider(
          authServer: server,
          openUrl: (url) {
            Uri uri = Uri.parse(url);
            Map<String, String> params = uri.queryParameters;
            if (params['client_id'] == MicrosoftAccount.CLIENT_ID &&
                params['response_type'] == 'code' &&
                params['redirect_uri'] == 'http://localhost:35129/msauth' &&
                params['scope'] == 'XboxLive.signin offline_access') {
              opened = true;
            }
          });
      await auth.login('A', 'B', (acc) => {},
          (error) => fail('Expected no errors, but received $error.'), client);
      expect(opened, true);

      await server.stop();
    });

    test('Login correctly sets the account callback for server.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthServer server = MicrosoftAuthServer(35129, client);

      bool called = false;
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(authServer: server, openUrl: (url) {});
      await auth.login('A', 'B', (acc) => called = true, (error) {}, client);
      server.accountCallback(MockAccount());
      expect(called, true);

      await server.stop();
    });

    test('Login correctly sets the error callback for server.', () async {
      final MockClient client = MockClient();
      final MicrosoftAuthServer server = MicrosoftAuthServer(35129, client);

      bool called = false;
      final MicrosoftAuthProvider auth =
          MicrosoftAuthProvider(authServer: server, openUrl: (url) {});
      await auth.login('A', 'B', (acc) {}, (error) => called = true, client);
      server.errorCallback('');
      expect(called, true);

      await server.stop();
    });
  });
}
