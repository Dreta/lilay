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
import 'package:lilay/ui/home/screen_provider.dart';
import 'package:provider/provider.dart';

/// Wrapping a screen in this widget creates
/// a fade animation between the screen's
/// shown/hidden state.
class AnimatedScreen extends StatelessWidget {
  static const int FADE_DURATION = 100;

  final ScreenType screenType;
  final Widget child;

  const AnimatedScreen({required this.screenType, required this.child});

  @override
  Widget build(BuildContext context) {
    final ScreenProvider screen = Provider.of<ScreenProvider>(context);

    return IgnorePointer(
        ignoring: screen.current != screenType,
        child: AnimatedOpacity(
            opacity: screen.current == screenType ? 1 : 0,
            duration: Duration(milliseconds: FADE_DURATION),
            curve: Curves.easeIn,
            child: child));
  }
}
