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

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/versions/latest_version.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:lilay/core/download/versions/versions_download_task.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:lilay/utils.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatefulWidget {
  final ProfileDialogType type;
  final Profile? profile;

  ProfileDialog({required this.type, required this.profile});

  static void display(
      BuildContext context, ProfileDialogType type, Profile? profile) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => ProfileDialog(type: type, profile: profile),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  _ProfileDialogState createState() =>
      _ProfileDialogState(type: type, profile: profile);
}

class _ProfileDialogState extends State<ProfileDialog> {
  final Profile profile;
  final ProfileDialogType type;
  late String _selectedVersion = versions.latest.release;
  late final VersionManifest versions;
  late VersionsDownloadTask task;

  _ProfileDialogState({required this.type, Profile? profile})
      : this.profile = profile ??
            Profile('', '', null, null, null, null,
                Profile.DEFAULT_JVM_ARGUMENTS, null, null);

  bool loaded = false;
  double? progress = 0;

  final GlobalKey<FormState> _form = GlobalKey();
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

  @override
  void initState() {
    super.initState();
    _name.text = profile.name;
    _selectedVersion = profile.version;
    _gameDir.text = profile.gameDirectory ?? '';
    _resWidth.text = profile.resolutionWidth == null
        ? ''
        : profile.resolutionWidth.toString();
    _resHeight.text = profile.resolutionHeight == null
        ? ''
        : profile.resolutionHeight.toString();
    _javaExec.text = profile.javaExecutable ?? '';
    _jvmArgs.text = profile.jvmArguments;
    _gameArgs.text = profile.gameArguments;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVersions(context);
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _versionFocus.dispose();
    _gameDirFocus.dispose();
    _resWidthFocus.dispose();
    _resHeightFocus.dispose();
    _jvmArgsFocus.dispose();
    _gameArgsFocus.dispose();
    _submitFocus.dispose();
    _gameDir.dispose();
    _resWidth.dispose();
    _resHeight.dispose();
    _javaExec.dispose();
    _jvmArgs.dispose();
    _gameArgs.dispose();
    task.cancelled = true;
  }

  /// Attempt to load the version manifest
  void _loadVersions(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);

    task = VersionsDownloadTask(
        source: config.metaSource, workingDir: config.workingDirectory);
    task.callbacks.add(() => setState(() => progress = task.progress));
    task.callbacks.add(() async {
      if (task.exception != null) {
        // Construct our own version manifest from the downloaded versions
        setState(
            () => progress = null); // Make the loading indicator indeterminate

        // Enumerate the versions/ directory for valid versions
        List<VersionInfo> versionObjs =
            await getAvailableVersionInfos(config.workingDirectory).toList();

        // Sort and determine the latest version
        versionObjs.sort((a, b) =>
            (a.releaseTime != null && b.releaseTime != null
                ? a.releaseTime!.compareTo(b.releaseTime!)
                : -1));
        String? latestRelease;
        String? latestSnapshot;
        for (VersionInfo version in versionObjs.reversed) {
          if (version.type == VersionType.snapshot && latestSnapshot == null) {
            latestSnapshot = version.id;
            continue;
          }
          if (version.type == VersionType.release && latestRelease == null) {
            latestRelease = version.id;
            continue;
          }
        }
        LatestVersion latest =
            LatestVersion(latestRelease ?? '', latestSnapshot ?? '');

        // Create the manifest
        setState(() {
          this.versions = VersionManifest(latest, versionObjs);
          if (type == ProfileDialogType.create) {
            _selectedVersion = latest.release;
          }
          loaded = true;
        });
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        task.save();
        List<VersionInfo> versionInfos =
            await getAvailableVersionInfos(config.workingDirectory).toList();
        setState(() {
          // Use the downloaded versions manifest
          VersionManifest manifest = task.result!;
          List<VersionInfo> applicable = [];
          List<String> applicableVers = [];
          DateTime minimumSupport =
              GetIt.I.get<DateTime>(instanceName: 'minimumSupport');
          // Remove legacy versions
          for (VersionInfo version in manifest.versions) {
            if (version.releaseTime!.compareTo(minimumSupport) >= 0) {
              applicable.add(version);
              applicableVers.add(version.id);
            }
          }
          // Add local versions
          for (VersionInfo version in versionInfos) {
            if (version.releaseTime != null &&
                version.releaseTime!.compareTo(minimumSupport) < 0) {
              continue;
            }
            if (applicableVers.contains(version.id)) {
              continue;
            }
            applicable.add(version);
          }
          manifest.versions = applicable;
          versions = manifest;
          if (type == ProfileDialogType.create) {
            _selectedVersion = versions.latest.release;
          }
          loaded = true;
        });
      }
    });
    task.start();
  }

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
    final CoreConfig config = Provider.of<CoreConfig>(context);

    final List<DropdownMenuItem<String>> items = [];
    final List<String> ids = [];

    for (VersionInfo version in versions.versions
      ..sort((a, b) => a.releaseTime != null && b.releaseTime != null
          ? a.releaseTime!.compareTo(b.releaseTime!)
          : -1)
      ..reversed) {
      // Legacy versions are not supported ATM
      if (version.type == VersionType.release ||
          (config.showSnapshots && version.type == VersionType.snapshot)) {
        items.add(DropdownMenuItem(value: version.id, child: Text(version.id)));
        ids.add(version.id);
      }
    }

    return Theme(
        child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
                labelText: 'Version',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor))),
            focusNode: _versionFocus,
            value: ids.contains(_selectedVersion) ? _selectedVersion : ids[0],
            items: items,
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

    return Row(children: [
      Expanded(
          child: Padding(
              padding: const EdgeInsets.only(right: 16),
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
                      labelText: 'Game Width',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.accentColor)))))),
      Expanded(
          child: TextFormField(
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
                  labelText: 'Game Height',
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.accentColor)))))
    ]);
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
                borderSide: BorderSide(color: theme.accentColor)),
            suffixIcon: IconButton(
                onPressed: () async {
                  FilePickerCross file =
                      await FilePickerCross.importFromStorage(
                          type: FileTypeCross.any);
                  if (file.path == null) {
                    _javaExec.text = '';
                    return;
                  }
                  _javaExec.text = file.path!;
                },
                tooltip: 'Browse',
                icon: Icon(Icons.folder))));
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
    final ProfilesProvider profiles = Provider.of<ProfilesProvider>(context);
    final ThemeData theme = Theme.of(context);

    return Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
        child: OverflowBar(
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            overflowDirection: VerticalDirection.down,
            overflowSpacing: 0,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (_form.currentState!.validate()) {
                      Logger logger = GetIt.I.get<Logger>();

                      profile.name = _name.value.text;
                      profile.version = _selectedVersion;
                      profile.gameDirectory = _gameDir.value.text.isEmpty
                          ? null
                          : _gameDir.value.text;
                      profile.resolutionWidth = _resWidth.value.text.isEmpty
                          ? null
                          : int.parse(_resWidth.value.text);
                      profile.resolutionHeight = _resHeight.value.text.isEmpty
                          ? null
                          : int.parse(_resHeight.value.text);
                      profile.javaExecutable = _javaExec.value.text.isEmpty
                          ? null
                          : _javaExec.value.text;
                      profile.jvmArguments = _jvmArgs.value.text.isEmpty
                          ? Profile.DEFAULT_JVM_ARGUMENTS
                          : _jvmArgs.value.text;
                      profile.gameArguments = _gameArgs.value.text.isEmpty
                          ? ''
                          : _gameArgs.value.text;
                      if (type == ProfileDialogType.create) {
                        profile.selected = profiles.profiles.length == 0;
                        if (profile.selected) {
                          profiles.selected = profile;
                        }
                        profiles.addProfile(profile);
                      } else {
                        profiles.notify();
                      }
                      profiles.saveTo(
                          GetIt.I.get<File>(instanceName: 'profilesDB'));
                      if (type == ProfileDialogType.create) {
                        logger.info('Created profile ${profile.name}.');
                      } else {
                        logger.info('Edited profile ${profile.name}.');
                      }
                      Navigator.pop(context);
                    }
                  },
                  focusNode: _submitFocus,
                  style: theme.elevatedButtonTheme.style,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: Text(type == ProfileDialogType.create
                          ? 'Create'
                          : 'Save')))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Dialog(
        child: Container(
            width: 512,
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                              type == ProfileDialogType.create
                                  ? 'Create a profile'
                                  : 'Edit ${profile.name}',
                              style: textTheme.headline6)),
                      loaded
                          ? Form(
                              key: _form,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildNameField(context),
                                    _buildVersionDropdown(context),
                                    _buildGameDirectoryField(context),
                                    Padding(
                                        child: _buildResolutionFields(context),
                                        padding:
                                            const EdgeInsets.only(bottom: 3)),
                                    _buildAdvancedTile(context),
                                    _buildSubmitButton(context)
                                  ]))
                          : Center(
                              child: CircularProgressIndicator(
                                  value: progress,
                                  backgroundColor: theme.backgroundColor),
                              heightFactor: 9)
                    ]))));
  }
}

enum ProfileDialogType { create, edit }
