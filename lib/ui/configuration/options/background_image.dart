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

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/configuration/core/types.dart';
import 'package:provider/provider.dart';

/// This widget handles the modification of
/// [CoreConfig.workingDirectory].
class BackgroundImage extends StatefulWidget {
  @override
  _BackgroundImageState createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<BackgroundImage> {
  final TextEditingController _selected = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected.text = Provider.of<CoreConfig>(context).backgroundImage ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _selected.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CoreConfig config = Provider.of<CoreConfig>(context);

    return TextField(
        controller: _selected,
        onEditingComplete: () {
          config.backgroundImage = _selected.text;
          if (_selected.text == '') {
            config.backgroundType = BackgroundType.asset;
            return;
          }
          config.backgroundType = BackgroundType.custom;
          config.save();
        },
        decoration: InputDecoration(
            labelText: 'Background image',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor)),
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  onPressed: () async {
                    FilePickerCross file =
                        await FilePickerCross.importFromStorage(
                            type: FileTypeCross.image);
                    if (file.path == null) {
                      config.backgroundImage = '';
                      config.backgroundType = BackgroundType.asset;
                      config.save();
                      _selected.text = '';
                      return;
                    }
                    config.backgroundImage = file.path;
                    config.backgroundType = BackgroundType.custom;
                    config.save();
                    _selected.text = file.path!;
                  },
                  tooltip: 'Browse',
                  icon: Icon(Icons.folder)),
              Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: IconButton(
                      onPressed: () async {
                        config.backgroundImage = '';
                        config.backgroundType = BackgroundType.asset;
                        config.save();
                        _selected.text = '';
                      },
                      tooltip: 'Reset',
                      icon: Icon(Icons.refresh, color: theme.errorColor)))
            ])));
  }
}
