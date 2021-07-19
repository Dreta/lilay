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

import 'dart:convert';

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:logging/logging.dart';

/// Provides the currently loaded profiles as a
/// globally accessible state.
class ProfilesProvider extends ChangeNotifier {
  final Map<int, Profile> _profiles = {};
  int? _selected;

  Profile? get selected => _selected == null ? null : _profiles[_selected!];

  Map<int, Profile> get profiles => _profiles;

  set selected(Profile? selected) {
    _selected = selected?.id;
    notifyListeners();
  }

  void loadFrom(File file) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Loading profiles from ${file.path}.');
    if (!await file.exists()) {
      return;
    }

    for (dynamic prof in jsonDecode(await file.readAsString())) {
      Profile profile = Profile.fromJson(prof as Map<String, dynamic>);
      logger.info('Loaded profile ${profile.name} (${profile.version}).');
      if (profile.selected) {
        _selected = profile.id;
      }
      _profiles[profile.id] = profile;
    }
    notifyListeners();
  }

  void saveTo(File file) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Saving profiles to ${file.path}.');
    List<Map<String, dynamic>> json = [];
    for (Profile profile in _profiles.values) {
      json.add(profile.toJson());
    }
    await file.writeAsString(jsonEncode(_profiles));
  }

  void notify() {
    notifyListeners();
  }

  /// Adds the profile to the map of profiles.
  ///
  /// Sets the ID to the maximum ID + 1 if the ID is -1.
  /// This must be called BEFORE saving the profile.
  void addProfile(Profile profile) {
    if (profile.id == -1) {
      int max = -1;
      for (int id in profiles.keys) {
        if (id > max) {
          max = id;
        }
      }
      profile.id = max;
    }

    _profiles[profile.id] = profile;
    notifyListeners();
  }

  void removeProfile(int profile) {
    _profiles.remove(profile);
    notifyListeners();
  }
}
