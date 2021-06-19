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
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:lilay/core/profile/game_manager.dart';
import 'package:lilay/ui/accounts/accounts_provider.dart';
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
      Navigator.pop(context);
      return Container();
    }
    final ThemeData theme = Theme.of(context);
    final GameManager manager = launch.manager!;
    if (manager.totalProgress >= 1) {
      manager.startGame(manager.data!, accounts.selectedAccount!);
      Navigator.pop(context);
      return Container();
    }

    if (manager.error == null) {
      return SimpleDialog(title: Text(manager.task!.text), children: [
        Center(
            child: CircularProgressIndicator(
                value: manager.totalProgress,
                backgroundColor: theme.backgroundColor),
            heightFactor: 9)
      ]);
    }
    return SimpleDialog(
        title: Text('Failed to start the game'),
        children: [Text(manager.error!)]);
  }
}
