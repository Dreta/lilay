import 'package:lilay/core/auth/account.dart';
import 'package:uuid/uuid.dart';

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
