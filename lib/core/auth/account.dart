import 'package:uuid/uuid.dart';

abstract class Account {
  const Account();

  String
      get username; // Username for unmigrated account, email for migrated accounts.
  // Not to be confused with getProfileName()
  String get accessToken;

  String get profileName;

  UuidValue get uuid;
}
