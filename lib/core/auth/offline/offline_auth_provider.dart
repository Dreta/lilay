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
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/offline/offline_account.dart';

/// OfflineAuthProvider creates an OfflineAccount for a given
/// username.
class OfflineAuthProvider extends AuthProvider {
  @override
  void login(String? username, String? password, Function(Account) callback) {
    assert(username != null);
    callback(OfflineAccount(name: username!));
  }

  @override
  bool requiresPassword() => false;

  @override
  bool canUseEmail() => false;

  @override
  bool requiresPayment() => false;

  @override
  String get name => 'Offline';

  @override
  String get type => 'offline';
}
