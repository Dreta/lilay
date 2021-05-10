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
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:provider/provider.dart';

class AssetsSource extends StatefulWidget {
  @override
  _AssetsSourceState createState() => _AssetsSourceState();
}

class _AssetsSourceState extends State<AssetsSource> {
  final TextEditingController _selected = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected.text = Provider.of<CoreConfig>(context).assetsSource;
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
          try {
            Uri.parse(_selected.text);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please enter a valid URL!'),
                duration: Duration(seconds: 3)));
            return;
          }

          config.downloadSource = // Remove the slash from the end of the URL
              _selected.text.endsWith('/')
                  ? _selected.text.substring(0, _selected.text.length - 1)
                  : _selected.text;
          _selected.text = config.downloadSource;
          config.save();
        },
        decoration: InputDecoration(
            labelText: 'Assets Source',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor)),
            suffixIcon: IconButton(
                onPressed: () async {
                  config.downloadSource =
                      'https://resources.download.minecraft.net';
                  config.save();
                  _selected.text = 'https://resources.download.minecraft.net';
                },
                tooltip: 'Reset',
                icon: Icon(Icons.refresh, color: theme.errorColor))));
  }
}
