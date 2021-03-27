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

import 'package:flutter/material.dart';
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

Logger logger = Logger('Lilay');
CoreConfig? coreConfig;

main() {
  logger.onRecord.listen((record) {
    print('[${record.level.name}] [${record.time}]: ${record.message}');
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

  logger.info('Setting up core config.');
  coreConfig = CoreConfig.fromFile(CoreConfig.defaultCoreConfig);

  runApp(Launcher());
}
