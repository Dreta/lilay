/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
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
import 'package:lilay/core/auth/offline/offline_auth_provider.dart';

void main() {
  group('OfflineAuthProvider', () {
    test('Account username correct after login.', () {
      final OfflineAuthProvider provider = OfflineAuthProvider();
      provider.login(
          null,
          'Dreta',
          null,
          (user) => expect(user.profileName, 'Dreta'),
          (error) => fail('Expected no errors, but received $error.'),
          null);
    });

    test('Fails when account username is null.', () {
      final OfflineAuthProvider provider = OfflineAuthProvider();
      provider.login(
          null,
          null,
          null,
          (user) => fail('Expected error, but received user $user.'),
          (error) => {},
          null);
    });
  });
}
