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

import 'package:uuid/uuid.dart';

/// Account represents an extensible account for custom Minecraft
/// authentication systems.
abstract class Account {
  const Account();

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
  UuidValue get uuid;

  /// Whether the user must re-authenticate to use
  /// this account. This happens when the access token
  /// is invalidated by the user.
  bool get requiresReauth;

  /// This method refreshes the accessToken for this account
  /// if it is unavailable.
  ///
  /// This method will be called when the account is loaded.
  Future<void> refresh();
}
