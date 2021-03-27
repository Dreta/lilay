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

import 'package:lilay/core/auth/auth_provider.dart';

/// Account represents an extensible account for custom Minecraft
/// authentication systems.
///
/// **Important**: Each authentication method must register themselves
/// with their respective types at [Account.authProviders] and
/// [Account.accountFactories].
abstract class Account {
  /// Maps string keys to their respective authentication provider.
  static final Map<String, AuthProvider> authProviders = Map();

  /// Maps string keys to their respective [Account] factory.
  static final Map<String, Function(Map<String, dynamic>)> accountFactories =
      Map();

  /// The default auth provider to use in the login dialog.
  static final defaultAuthProvider = 'yggdrasil';

  /// This is the username that the user types in when
  /// signing in.
  ///
  /// This is an email for Mojang accounts and a username
  /// for legacy accounts.
  ///
  /// Not to be confused with [profileName].
  String get username;

  /// This is a valid access token of the user.
  String get accessToken;

  /// This is the in-game-name of the user.
  String get profileName;

  /// This is the unique ID assigned to the user.
  String get uuid;

  /// This is the type of this account. It is used to
  /// identify which [accountFactories] factories should
  /// be used to load this account.
  String get type;

  /// Whether the user must re-authenticate to use
  /// this account. This happens when the access token
  /// is invalidated by the user.
  bool get requiresReauth;

  /// Whether this is the account that the user selected.
  bool get selected;

  /// Whether the user have paid for a Minecraft license.
  bool get paid;

  /// Set whether this account is selected.
  set selected(bool sel);

  /// Get the auth provider that loaded this account.
  AuthProvider get authProvider => authProviders[type]!;

  /// This method refreshes the accessToken for this account
  /// if it is unavailable.
  ///
  /// This method will be called when the account is loaded.
  Future<void> refresh();

  /// Manually convert this class to JSON.
  /// Individual subclasses might want to override this method
  /// for extra control over how to serialize.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'accessToken': accessToken,
      'profileName': profileName,
      'type': type,
      'uuid': uuid,
      'requiresReauth': requiresReauth,
      'selected': selected
    };
  }
}
