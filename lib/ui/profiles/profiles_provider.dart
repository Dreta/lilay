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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lilay/core/profile/profile.dart';

/// Provides the currently loaded profiles as a
/// globally accessible state.
class ProfilesProvider extends ChangeNotifier {
  final List<Profile> _profiles = [];
  Profile? _selected;

  Profile? get selected => _selected;

  List<Profile> get profiles => _profiles;

  set selected(Profile? selected) {
    _selected = selected;
    notifyListeners();
  }

  void loadFrom(File file) async {
    if (!await file.exists()) {
      return;
    }

    for (dynamic prof in jsonDecode(await file.readAsString())) {
      Profile profile = Profile.fromJson(prof as Map<String, dynamic>);
      if (profile.selected) {
        _selected = profile;
      }
      _profiles.add(profile);
    }
    notifyListeners();
  }

  void saveTo(File file) async {
    List<Map<String, dynamic>> json = [];
    for (Profile profile in _profiles) {
      json.add(profile.toJson());
    }
    await file.writeAsString(jsonEncode(_profiles));
  }

  void addProfile(Profile profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void removeProfile(Profile profile) {
    _profiles.remove(profile);
    notifyListeners();
  }
}
