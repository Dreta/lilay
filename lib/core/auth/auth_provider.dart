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

import 'package:lilay/core/auth/account.dart';

/// AuthProvider allows other classes to provide custom
/// authentication methods (e.g. Yggdrasil, authlib-injector)
abstract class AuthProvider {
  /// Whether this authentication method requires a password.
  /// e.g. Logging in to an offline account does not require
  ///      a password.
  bool requiresPassword();

  /// Create an account object with a username and a password.
  Future<Account> login(String username, String? password);
}
