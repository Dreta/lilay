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

import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:uuid/uuid.dart';

/// OfflineAccount represents a Minecraft offline account (does not require login)
class OfflineAccount extends Account {
  /// Create an instance of [OfflineAccount] from a saved JSON state.
  static final Function(Map<String, dynamic>) fromJson =
      (Map<String, dynamic> json) {
    OfflineAccount account = OfflineAccount._();
    account._name = json['username'];
    account._uuid = json['uuid'];
    account.selected = json['selected'];
    return account;
  };

  late String _name;
  late String _uuid = Uuid().v4obj().uuid;
  late bool selected = false;

  OfflineAccount._();

  OfflineAccount({required String name}) : this._name = name;

  @override
  String get accessToken => 'nevergonnagiveyouup';

  @override
  String get username => _name;

  @override
  String get profileName => _name;

  @override
  String get uuid => _uuid;

  // An offline account never needs to be refreshed.
  @override
  Future<void> refresh(Client client) async {}

  // An offline account never needs to be paid for.
  @override
  Future<void> updatePaymentStatus(Client client) async {}

  // An offline account never needs re-authentication.
  @override
  bool get requiresReauth => false;

  @override
  String get type => 'offline';

  @override
  bool get paid => true;

  @override
  Future<void> invalidate(Client client) async {}
}
