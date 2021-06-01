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
import 'package:lilay/core/profile/profile.dart';

/// This widget represents a game profile in Lilay.
class ProfileWidget extends StatelessWidget {
  final Profile profile;
  final bool openScreen;

  const ProfileWidget({required this.profile, required this.openScreen});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
        leading: Icon(Icons.sports_esports, color: theme.accentColor),
        trailing: openScreen ? Icon(Icons.menu) : null,
        title: Text(profile.name),
        subtitle: Text(profile.version),
        minLeadingWidth: 20);
  }
}
