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

import 'package:flutter/material.dart';
import 'package:lilay/core/auth/account.dart';

class AccountsProvider extends ChangeNotifier {
  final Map<String, Account> _accounts = {};

  /// Get the stored accounts.
  Iterable<Account> get accounts => _accounts.values;

  /// Adds an account to this accounts provider.
  void addAccount(Account account) {
    _accounts[account.uuid] = account;
    notifyListeners();
  }

  /// Removes an account from this accounts provider.
  void removeAccount(String uuid) {
    _accounts.remove(uuid);
    notifyListeners();
  }
}
