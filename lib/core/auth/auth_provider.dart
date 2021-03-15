import 'package:lilay/core/auth/account.dart';

abstract class AuthProvider {
  bool requiresPassword();

  Future<Account> login(String username, String? password);
}
