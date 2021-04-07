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
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/home/home.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AccountsProvider provider = AccountsProvider();
    provider.loadFrom(GetIt.I.get<File>(instanceName: 'accountsDB'));

    final CoreConfig coreConfig =
        CoreConfig.fromFile(CoreConfig.defaultCoreConfig);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: ScreenProvider()),
          ChangeNotifierProvider.value(value: coreConfig)
        ],
        child: MaterialApp(
          title: 'Lilay',
          theme: ThemeData.light(),
          home: Homepage(),
        ));
  }
}
