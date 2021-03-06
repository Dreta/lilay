// @dart=2.9
// Unfortunately the file_picker_cross library is not null-safe,
// and I don't think there's an alternative for it.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_provider.dart';
import 'package:lilay/core/auth/offline/offline_account.dart';
import 'package:lilay/core/auth/offline/offline_auth_provider.dart';
import 'package:lilay/core/auth/yggdrasil/yggdrasil_account.dart';
import 'package:lilay/core/auth/yggdrasil/yggdrasil_auth_provider.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/app.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:lilay/ui/launch/launch_provider.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:lilay/utils.dart';
import 'package:logging/logging.dart';
import 'package:open_url/open_url.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() async {
  Logger logger = Logger('Lilay');
  logger.onRecord.listen((record) {
    print('[${record.level.name}] [${record.time}]: ${record.message}');
  });
  GetIt.I.registerSingleton<Logger>(logger);

  FileSystem fs = const LocalFileSystem();
  GetIt.I.registerSingleton<FileSystem>(fs);
  GetIt.I.registerSingleton<String>('1.0.0', instanceName: 'version');
  GetIt.I.registerSingleton<DateTime>(DateTime(2013, 10, 25, 13),
      instanceName: 'minimumSupport');

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('font/UFL.txt');
    yield LicenseEntryWithLineBreaks(['ubuntu_font'], license);
  });

  logger.info('Registering authentication methods.');

  // Yggdrasil
  Account.authProviders['yggdrasil'] = YggdrasilAuthProvider();
  Account.accountFactories['yggdrasil'] = YggdrasilAccount.fromJson;

  // Offline
  Account.authProviders['offline'] = OfflineAuthProvider();
  Account.accountFactories['offline'] = OfflineAccount.fromJson;

  // Microsoft
  Account.authProviders['microsoft'] =
      MicrosoftAuthProvider(httpClient: Client(), openUrl: openUrl);
  Account.accountFactories['microsoft'] = MicrosoftAccount.fromJson;

  logger.info('Setting up cache directory.');
  Directory cacheDirectory = fs.directory('cache');
  GetIt.I.registerSingleton<Directory>(cacheDirectory, instanceName: 'cache');
  if (!cacheDirectory.existsSync()) {
    cacheDirectory.createSync();
  }

  logger.info('Loading accounts.');
  GetIt.I.registerSingleton<File>(fs.file('accounts.json'),
      instanceName: 'accountsDB');

  final AccountsProvider accounts = AccountsProvider();
  accounts.loadFrom(GetIt.I.get<File>(instanceName: 'accountsDB'));

  logger.info('Loading profiles.');
  GetIt.I.registerSingleton<File>(fs.file('profiles.json'),
      instanceName: 'profilesDB');

  final ProfilesProvider profiles = ProfilesProvider();
  profiles.loadFrom(GetIt.I.get<File>(instanceName: 'profilesDB'));

  logger.info('Loading configuration.');
  final CoreConfig coreConfig =
      CoreConfig.fromFile(CoreConfig.defaultCoreConfig);

  logger.info('Detecting Java installation.');
  String java = await detectJavaInstallation();
  GetIt.I.registerSingleton<String>(java, instanceName: 'java');

  logger.info('Starting app.');
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle('Lilay');
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: accounts),
    ChangeNotifierProvider.value(value: profiles),
    ChangeNotifierProvider.value(value: ScreenProvider()),
    ChangeNotifierProvider.value(value: coreConfig),
    ChangeNotifierProvider.value(value: LaunchProvider())
  ], child: App()));
}
