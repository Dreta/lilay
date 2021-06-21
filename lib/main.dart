// @dart=2.9
// Unfortunately the file_picker_cross library is not null-safe,
// and I don't think there's an alternative for it.

/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Lilay is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Lilay.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_provider.dart';
import 'package:lilay/core/auth/microsoft/microsoft_auth_server.dart';
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
import 'package:provider/provider.dart';

void main() async {
  Logger logger = Logger('Lilay');
  logger.onRecord.listen((record) {
    print('[${record.level.name}] [${record.time}]: ${record.message}');
  });
  GetIt.I.registerSingleton<Logger>(logger);

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
      MicrosoftAuthProvider(authServer: MicrosoftAuthServer(35129));
  Account.accountFactories['microsoft'] = MicrosoftAccount.fromJson;

  logger.info('Setting up cache directory.');
  Directory cacheDirectory = Directory('cache');
  GetIt.I.registerSingleton<Directory>(cacheDirectory, instanceName: 'cache');
  if (!cacheDirectory.existsSync()) {
    cacheDirectory.createSync();
  }

  logger.info('Loading accounts.');
  GetIt.I.registerSingleton<File>(File('accounts.json'),
      instanceName: 'accountsDB');

  final AccountsProvider accounts = AccountsProvider();
  accounts.loadFrom(GetIt.I.get<File>(instanceName: 'accountsDB'));

  logger.info('Loading profiles.');
  GetIt.I.registerSingleton<File>(File('profiles.json'),
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
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: accounts),
    ChangeNotifierProvider.value(value: profiles),
    ChangeNotifierProvider.value(value: ScreenProvider()),
    ChangeNotifierProvider.value(value: coreConfig),
    ChangeNotifierProvider.value(value: LaunchProvider())
  ], child: App()));
}
