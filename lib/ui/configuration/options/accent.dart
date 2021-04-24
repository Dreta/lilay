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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:provider/provider.dart';

class AccentColor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);
    return ListTile(
        title: Text('Accent color'),
        onTap: () {
          showAnimatedDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                  title: Text('Set the accent color'),
                  content: SingleChildScrollView(
                      child: BlockPicker(
                          pickerColor: Colors.primaries[config.accent],
                          availableColors: [
                            Colors.red,
                            Colors.pink,
                            Colors.purple,
                            Colors.deepPurple,
                            Colors.indigo,
                            Colors.blue,
                            Colors.lightBlue,
                            Colors.cyan,
                            Colors.teal,
                            Colors.green,
                            Colors.lightGreen,
                            Colors.lime,
                            Colors.yellow,
                            Colors.amber,
                            Colors.orange,
                            Colors.deepOrange
                          ],
                          onColorChanged: (color) {
                            config.accent = Colors.primaries
                                .indexOf(color as MaterialColor);
                            config.save();
                            config.write(CoreConfig.defaultCoreConfig);
                            Navigator.pop(context);
                          }))),
              animationType: DialogTransitionType.fadeScale,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 400));
        });
  }
}
