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
  bool requiresPassword() => true;

  /// Whether this authentication method does not use the standard
  /// username-password prompts that's built-in.
  /// e.g. Microsoft account requires a webview.
  bool useManualAuthentication() => false;

  /// Whether this authentication method allows you to use an email
  /// to authenticate.
  bool canUseEmail() => true;

  /// Get the human-friendly name of this [AuthProvider].
  String get name;

  /// Get the type of the respective [Account] for this [AuthProvider].
  String get type;

  /// Create an account object with a username and a password.
  ///
  /// [callback] should probably be done with a [Future] instead,
  /// however in [MicrosoftAuthProvider], I can't think of a way to
  /// integrate a [Future] into it. Please PR if you have a good idea.
  void login(String? username, String? password, Function(Account) callback);
}
