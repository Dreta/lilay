import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/offline/offline_account.dart';

class OfflineAuthProvider extends AuthProvider {
  @override
  Future<Account> login(String username, String? password) async {
    return OfflineAccount(name: username);
  }

  @override
  bool requiresPassword() {
    return false;
  }
}
