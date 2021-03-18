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
import 'package:uuid/uuid.dart';

/// OfflineAccount represents a Minecraft offline account (does not require login)
class OfflineAccount extends Account {
  final String _name;
  final UuidValue _uuid = Uuid().v4obj();

  OfflineAccount({required String name}) : this._name = name;

  @override
  String get accessToken =>
      throw UnimplementedError(); // Offline accounts don't get an access token

  @override
  String get username => _name;

  @override
  String get profileName => _name;

  @override
  UuidValue get uuid => _uuid;
}
