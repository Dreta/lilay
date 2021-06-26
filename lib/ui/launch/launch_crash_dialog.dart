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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class LaunchCrashDialog extends StatelessWidget {
  static void display(BuildContext context) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => LaunchCrashDialog(),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Game crashed'),
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
        content:
            const Text('For detailed information, please read the game log.'),
        actions: [
          TextButton(
              child: Text('Okay'), onPressed: () => Navigator.of(context).pop())
        ]);
  }
}
