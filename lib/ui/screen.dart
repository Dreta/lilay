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

import 'package:flutter/material.dart';

/// This is the basis for all Lilay screens.
class Screen extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const Screen({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: textTheme.headline5),
          Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child:
                  Divider(height: 1, thickness: 1, color: theme.dividerColor)),
          ...children
        ]));
  }
}
