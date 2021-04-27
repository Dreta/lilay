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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:logging/logging.dart';

/// Provides the currently loaded accounts as a
/// globally accessible state.
class AccountsProvider extends ChangeNotifier {
  final Map<String, Account> _accounts = {};
  LoadingStatus _loadingStatus = LoadingStatus.none;
  String? _selectedAccountUUID;

  LoadingStatus get loadingStatus => _loadingStatus;

  Iterable<Account> get accounts => _accounts.values;

  Account? get selectedAccount {
    if (_selectedAccountUUID == null) {
      return null;
    }
    return getAccountByUUID(_selectedAccountUUID!);
  }

  set selectedAccount(Account? account) {
    if (account == null) {
      _selectedAccountUUID = null;
      return;
    }
    _selectedAccountUUID = account.uuid;
    notifyListeners();
  }

  Account? getAccountByUUID(String uuid) => _accounts[uuid];

  void loadFrom(File file) async {
    if (!await file.exists()) {
      // Do not load for non-existent files, however
      // set the loaded state.
      _loadingStatus = LoadingStatus.loaded;
      notifyListeners();
      return;
    }

    _loadingStatus = LoadingStatus.loading;
    notifyListeners();

    for (Map<String, dynamic> account
        in (jsonDecode(await file.readAsString())['accounts']
            as List<dynamic>)) {
      String? type = account['type'];
      if (type == null) {
        GetIt.I.get<Logger>().severe('Found invalid account without type');
        continue;
      }
      Account acc = Account.accountFactories[account['type']]!(account);
      try {
        await acc.refresh();
      } catch (e) {
        _loadingStatus = LoadingStatus.failed;
        notifyListeners();
        break;
      }

      if (acc.selected) {
        _selectedAccountUUID = acc.uuid;
      }
      addAccount(acc); // This implicitly runs notifyListeners().
    }
    _loadingStatus = LoadingStatus.loaded;
    notifyListeners();
  }

  void saveTo(File file) async {
    List<Map<String, dynamic>> json = [];
    for (Account account in accounts) {
      json.add(account.toJson());
    }
    await file.writeAsString(jsonEncode({'accounts': json}));
  }

  void addAccount(Account account) {
    _accounts[account.uuid] = account;
    notifyListeners();
  }

  void removeAccount(String uuid) {
    _accounts.remove(uuid);
    notifyListeners();
  }
}

enum LoadingStatus { none, loading, failed, loaded }
