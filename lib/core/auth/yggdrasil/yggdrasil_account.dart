import 'package:lilay/core/auth/account.dart';
import 'package:lilay/utils.dart';
import 'package:uuid/uuid.dart';

class YggdrasilAccount extends Account {
  final Map<String, dynamic> jsonValue;

  const YggdrasilAccount({required this.jsonValue});

  @override
  String get accessToken => jsonValue['accessToken'];

  @override
  String get profileName => jsonValue['selectedProfile']['name'];

  @override
  String get username => jsonValue['user']['username'];

  @override
  UuidValue get uuid =>
      UuidValue(dashifyUUID(jsonValue['selectedProfile']['id']));
}
