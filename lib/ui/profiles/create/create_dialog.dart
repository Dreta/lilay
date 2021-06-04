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
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';

class CreateDialog extends StatefulWidget {
  @override
  _CreateDialogState createState() => _CreateDialogState();
}

class _CreateDialogState extends State<CreateDialog> {
  late String _selectedVersion;
  late VersionManifest versions;

  final TextEditingController _name = TextEditingController();
  final FocusNode _versionFocus = FocusNode();
  final FocusNode _gameDirFocus = FocusNode();
  final FocusNode _resWidthFocus = FocusNode();
  final FocusNode _resHeightFocus = FocusNode();
  final FocusNode _jvmArgsFocus = FocusNode();
  final FocusNode _gameArgsFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();
  final TextEditingController _gameDir = TextEditingController();
  final TextEditingController _resWidth = TextEditingController();
  final TextEditingController _resHeight = TextEditingController();
  final TextEditingController _javaExec = TextEditingController();
  final TextEditingController _jvmArgs = TextEditingController();
  final TextEditingController _gameArgs = TextEditingController();

  /// Create the profile name field
  Widget _buildNameField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _name,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Name is required.' : null,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            FocusScope.of(context).requestFocus(_versionFocus),
        decoration: InputDecoration(
            labelText: 'Name',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the version dropdown
  Widget _buildVersionDropdown(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Theme(
        child: DropdownButtonFormField(
            decoration: InputDecoration(
                labelText: 'Version',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor))),
            focusNode: _versionFocus,
            value: _selectedVersion,
            items: [
              for (VersionInfo version in versions.versions
                ..sort((a, b) => a.releaseTime.compareTo(b.releaseTime))
                ..reversed)
                DropdownMenuItem(value: version.id, child: Text(version.id))
            ],
            onChanged: (value) {
              setState(() {
                _selectedVersion = value as String;
              });
            }),
        data: Theme.of(context)
            .copyWith(canvasColor: theme.dialogBackgroundColor));
  }

  /// Create the game directory text field
  Widget _buildGameDirectoryField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        cursorColor: theme.textSelectionTheme.cursorColor,
        focusNode: _gameDirFocus,
        controller: _gameDir,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          try {
            Directory(value);
          } catch (e) {
            return 'Invalid path';
          }
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            FocusScope.of(context).requestFocus(_resWidthFocus),
        decoration: InputDecoration(
            labelText: 'Game Directory',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the resolution fields
  Widget _buildResolutionFields(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
        child: Row(children: [
      Padding(
          padding: EdgeInsets.only(right: 16),
          child: TextFormField(
              cursorColor: theme.textSelectionTheme.cursorColor,
              focusNode: _resWidthFocus,
              controller: _resWidth,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null) {
                  return 'Invalid number';
                }
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(_resHeightFocus),
              decoration: InputDecoration(
                  labelText: 'Width',
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.accentColor))))),
      TextFormField(
          cursorColor: theme.textSelectionTheme.cursorColor,
          focusNode: _resHeightFocus,
          controller: _resHeight,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            if (double.tryParse(value) == null) {
              return 'Invalid number';
            }
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (value) =>
              FocusScope.of(context).requestFocus(_submitFocus),
          decoration: InputDecoration(
              labelText: 'Height',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor))))
    ]));
  }

  /// Create the Java executable field
  Widget _buildJavaExecField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _javaExec,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          try {
            File file = File(value);
            if (!file.existsSync()) {
              return 'Can\'t find this executable';
            }
          } catch (e) {
            return 'Invalid path';
          }
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            FocusScope.of(context).requestFocus(_jvmArgsFocus),
        decoration: InputDecoration(
            labelText: 'Java Executable',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the JVM arguments field
  Widget _buildJVMArgsField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _jvmArgs,
        focusNode: _jvmArgsFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            FocusScope.of(context).requestFocus(_gameArgsFocus),
        decoration: InputDecoration(
            labelText: 'JVM Arguments',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the game arguments field
  Widget _buildGameArgsField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _gameArgs,
        focusNode: _gameArgsFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            FocusScope.of(context).requestFocus(_submitFocus),
        decoration: InputDecoration(
            labelText: 'Game Arguments',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the "Advanced" expansion tile
  Widget _buildAdvancedTile(BuildContext context) {
    return ExpansionTile(title: Text('Advanced'), children: [
      _buildJavaExecField(context),
      _buildJVMArgsField(context),
      _buildGameArgsField(context)
    ]);
  }

  /// Create the submit button
  Widget _buildSubmitButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.fromLTRB(8, 24, 8, 8),
        child: OverflowBar(
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            overflowDirection: VerticalDirection.down,
            overflowSpacing: 0,
            children: [
              ElevatedButton(
                  onPressed: () => {}, // TODO
                  focusNode: _submitFocus,
                  style: theme.elevatedButtonTheme.style,
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: Text('Create')))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create a profile'),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(context),
            _buildVersionDropdown(context),
            _buildGameDirectoryField(context),
            _buildResolutionFields(context),
            _buildAdvancedTile(context)
          ]),
      actions: [_buildSubmitButton(context)],
    );
  }
}
