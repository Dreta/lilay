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

/// Provides the currently selected screen as a globally
/// accessible state.
class ScreenProvider extends ChangeNotifier {
  ScreenType _currentScreen = ScreenType.home;

  ScreenType get current => _currentScreen;

  set current(ScreenType s) {
    _currentScreen = s;
    notifyListeners();
  }
}

/// Implemented screens in Lilay.
enum ScreenType { home, accounts, configuration }
