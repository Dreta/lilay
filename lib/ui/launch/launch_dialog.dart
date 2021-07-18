/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
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
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:lilay/core/profile/game_manager.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
import 'package:lilay/ui/launch/launch_crash_dialog.dart';
import 'package:provider/provider.dart';

import 'launch_provider.dart';

class LaunchDialog extends StatelessWidget {
  static void display(BuildContext context) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => LaunchDialog(),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final LaunchProvider launch = Provider.of<LaunchProvider>(context);
    final AccountsProvider accounts = Provider.of<AccountsProvider>(context);
    if (launch.manager == null) {
      return SimpleDialog(title: Text('Game unavailable'), children: [
        Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Text('Invalid call. Please start the game again.'))
      ]);
    }
    final ThemeData theme = Theme.of(context);
    final GameManager manager = launch.manager!;
    // I can't believe that I can't find a method to simply round to
    // five digits.
    // The reason that we round is percentages like 0.9999999999999829 exist.
    if (double.parse(manager.totalProgress.toStringAsFixed(5)) >= 1 &&
        launch.status == LaunchStatus.starting) {
      manager.startGame(manager.data!, accounts.selectedAccount!);
    }

    if (launch.status == LaunchStatus.started) {
      return SimpleDialog(title: Text('Game launched'), children: [
        Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Text('You can close this dialog now.'))
      ]);
    }

    if (launch.crashed) {
      return LaunchCrashDialog();
    }

    if (manager.error == null) {
      return SimpleDialog(title: Text('Starting game'), children: [
        SizedBox(
            width: 512,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: Text(manager.task!.text,
                          style: theme.textTheme.subtitle2)),
                  if (manager.subtitle != null)
                    Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Text(manager.subtitle!)),
                  Center(
                      child: CircularProgressIndicator(
                          value: manager.totalProgress,
                          backgroundColor: theme.backgroundColor),
                      heightFactor: 9)
                ]))
      ]);
    }
    return SimpleDialog(title: Text('Failed to start the game'), children: [
      Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
          child: SizedBox(width: 512, child: Text(manager.error!)))
    ]);
  }
}
