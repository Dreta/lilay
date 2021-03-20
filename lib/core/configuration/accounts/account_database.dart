import 'dart:convert';
import 'dart:io';

import 'package:lilay/core/auth/account.dart';
import 'package:lilay/main.dart';

/// Contains all the login information that you have saved
/// in Lilay.
class AccountDatabase {
  /// This is where the account database will be loaded from.
  static final File defaultAccountDB = File('accounts.json');

  final File _file;
  late List<Account> _loadedAccounts;

  AccountDatabase({required File file}) : _file = file {
    if (file.existsSync()) {
      _load(file);
    }
  }

  File get file => _file;

  List<Account> get accounts => _loadedAccounts;

  /// Load the saved accounts from a file.
  void _load(File file) async {
    for (Map<String, dynamic> account
        in (jsonDecode(await file.readAsString())['accounts']
            as List<Map<String, dynamic>>)) {
      String? type = account['type'];
      if (type == null) {
        logger.severe('Found invalid account without type');
        continue;
      }
      _loadedAccounts.add(Account.accountFactories[type]!(account));
    }
  }

  /// Save the accounts to the data file.
  void save() async {
    List<Map<String, dynamic>> json = [];
    for (Account account in _loadedAccounts) {
      json.add(account.toJson());
    }
    await _file.writeAsString(jsonEncode({'accounts': json}));
  }
}
