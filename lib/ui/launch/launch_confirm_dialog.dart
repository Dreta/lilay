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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class LaunchConfirmDialog extends StatelessWidget {
  final Function onConfirm;

  const LaunchConfirmDialog({required this.onConfirm});

  static void display(BuildContext context, Function onConfirm) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => LaunchConfirmDialog(onConfirm: onConfirm),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Are you sure?'),
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
        actionsPadding: const EdgeInsets.only(bottom: 24, right: 12),
        content: const Text(
            'Another game is already running.\nStarting multiple instances of the game might cause issues.'),
        actions: [
          TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
              child: Text('Start'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              })
        ]);
  }
}
