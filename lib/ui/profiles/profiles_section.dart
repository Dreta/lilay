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
import 'package:lilay/ui/profiles/create_button.dart';
import 'package:lilay/ui/profiles/profile.dart';
import 'package:lilay/ui/profiles/profiles_provider.dart';
import 'package:provider/provider.dart';

class ProfilesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProfilesProvider profiles = Provider.of<ProfilesProvider>(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
          child: Text('PROFILES', style: textTheme.subtitle2)),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor)),
      if (profiles.selected != null)
        ProfileWidget(profile: profiles.selected!, openScreen: true),
      CreateButton()
    ]);
  }
}
