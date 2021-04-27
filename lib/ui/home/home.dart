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
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/accounts/screen/accounts_screen.dart';
import 'package:lilay/ui/animated_screen.dart';
import 'package:lilay/ui/configuration/configuration_screen.dart';
import 'package:lilay/ui/home/navigation_drawer.dart';
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:provider/provider.dart';

/// This widget represents the main page of Lilay,
/// consisting of the accounts, the game profiles
/// and the play button.
class Homepage extends StatelessWidget {
  void deleteAccount(BuildContext context, Account account) {
    final ScreenProvider screen =
        Provider.of<ScreenProvider>(context, listen: false);
    final AccountsProvider accounts =
        Provider.of<AccountsProvider>(context, listen: false);

    if (accounts.accounts.length == 1) {
      accounts.selectedAccount = null;
      screen.current = ScreenType.home;
    } else if (account.selected) {
      account.selected = false;
      for (Account account in accounts.accounts) {
        if (account.uuid != account.uuid) {
          accounts.selectedAccount = account;
          break;
        }
      }
    }
    accounts.removeAccount(account.uuid);
    accounts.saveTo(GetIt.I.get<File>(instanceName: 'accountsDB'));
  }

  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);

    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: (config.backgroundType == BackgroundType.asset
                            ? AssetImage('assets/background.png')
                            : FileImage(File(config.backgroundImage!)))
                        as ImageProvider,
                    fit: BoxFit.cover)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              NavigationDrawer(),
              Expanded(
                  child: Stack(children: [
                AnimatedScreen(
                    screenType: ScreenType.accounts,
                    child: AccountsScreen(
                        onAccountDelete: (account) =>
                            deleteAccount(context, account))),
                AnimatedScreen(
                    screenType: ScreenType.configuration,
                    child: ConfigurationScreen())
              ]))
            ])));
  }
}
