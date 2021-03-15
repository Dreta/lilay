import 'package:uuid/uuid.dart';

abstract class Account {
  const Account();

  String
      get username; // Username for unmigrated account, email for migrated accounts.
  // Not to be confused with getProfileName()
  String get accessToken;

  String get email;

  bool get suspended;

  bool get blocked;

  bool get secured;

  bool get emailVerified;

  bool get legacy;

  bool get verifiedByParent;

  String get profileName;

  UuidValue get uuid;

  DateTime get createdAt;
}
