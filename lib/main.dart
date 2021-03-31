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

import 'package:flutter/material.dart';
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
import 'package:lilay/ui/launcher.dart';
import 'package:logging/logging.dart';

main() {
  Logger logger = Logger('Lilay');
  logger.onRecord.listen((record) {
    print('[${record.level.name}] [${record.time}]: ${record.message}');
  });
  GetIt.I.registerSingleton<Logger>(logger);

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

  logger.info('Setting up core config.');
  CoreConfig coreConfig = CoreConfig.fromFile(CoreConfig.defaultCoreConfig);
  GetIt.I.registerSingleton<CoreConfig>(coreConfig);

  logger.info('Setting up cache directory.');
  Directory cacheDirectory = Directory('cache');
  GetIt.I.registerSingleton<Directory>(cacheDirectory, instanceName: 'cache');
  if (!cacheDirectory.existsSync()) {
    cacheDirectory.createSync();
  }

  runApp(Launcher());
}
