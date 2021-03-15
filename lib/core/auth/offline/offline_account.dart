import 'package:lilay/core/auth/account.dart';
import 'package:uuid/uuid.dart';

class OfflineAccount extends Account {
  final String _name;
  final UuidValue _uuid = Uuid().v4obj();
  final DateTime _createdAt = DateTime.now();

  OfflineAccount({required String name}) : this._name = name;

  @override
  String get accessToken {
    throw UnimplementedError(); // Offline accounts don't get an access token
  }

  @override
  String get email {
    throw UnimplementedError(); // Offline accounts don't get an email
  }

  @override
  String get username {
    return _name;
  }

  @override
  bool get blocked {
    return false;
  }

  @override
  bool get emailVerified {
    throw UnimplementedError(); // Offline accounts don't get an email
  }

  @override
  bool get legacy {
    return false;
  }

  @override
  bool get suspended {
    return false;
  }

  @override
  bool get verifiedByParent {
    return false;
  }

  @override
  bool get secured {
    return true; // So we won't show the security questions alert
  }

  @override
  DateTime get createdAt {
    return _createdAt;
  }

  @override
  String get profileName {
    return _name;
  }

  @override
  UuidValue get uuid {
    return _uuid;
  }
}
