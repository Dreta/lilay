import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_server.dart';
import 'package:open_url/open_url.dart';

/// MicrosoftAuthProvider logs a user into their Microsoft account.
class MicrosoftAuthProvider extends AuthProvider {
  final MicrosoftAuthServer _authServer;

  MicrosoftAuthProvider({required MicrosoftAuthServer authServer})
      : _authServer = authServer;

  @override
  void login(
      String? username, String? password, Function(Account) callback) async {
    // This is where we will have to visit.
    String authUrl =
        'https://login.live.com/oauth20_authorize.srf?client_id=${MicrosoftAccount.CLIENT_ID}'
        '&response_type=code'
        '&redirect_uri=http%3A%2F%2Flocalhost%3A35129%2Fmsauth'
        '&scope=XboxLive.signin%20offline_access';

    // Open the browser window.
    openUrl(authUrl);

    // Make the auth server use the callback we have from the user.
    _authServer.accountCallback = callback;
  }

  @override
  bool requiresPassword() => false;

  @override
  bool useManualAuthentication() => true;
}
