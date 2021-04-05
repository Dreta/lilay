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

class DeleteDialog extends StatelessWidget {
  final Function onConfirm;

  const DeleteDialog({required this.onConfirm});

  static display(BuildContext context, Function onConfirm) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => DeleteDialog(onConfirm: onConfirm),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
        title: const Text('Are you sure?'),
        contentPadding:
            EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
        actionsPadding: EdgeInsets.only(bottom: 24, right: 12),
        content:
            const Text('You will have to re-login to use this account again!'),
        actions: [
          TextButton(
              child: Text('CANCEL',
                  style: TextStyle(color: theme.primaryColorDark)),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(theme.errorColor)),
              child: Text('DELETE', style: TextStyle(color: Colors.white)),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Your account was deleted.'),
                    duration: Duration(seconds: 3)));
              })
        ]);
  }
}
