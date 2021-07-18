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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:provider/provider.dart';

/// This widget handles the modification of
/// [CoreConfig.preferredLoginType].
class PreferredLoginType extends StatefulWidget {
  @override
  _PreferredLoginTypeState createState() => _PreferredLoginTypeState();
}

class _PreferredLoginTypeState extends State<PreferredLoginType> {
  late String _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected = Provider.of<CoreConfig>(context).preferredLoginType;
  }

  @override
  Widget build(BuildContext context) {
    final CoreConfig config = Provider.of<CoreConfig>(context);
    final ThemeData theme = Theme.of(context);

    return Row(children: [
      Expanded(
          child: DropdownButtonFormField(
              decoration: InputDecoration(
                  labelText: 'Preferred Account Type',
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.accentColor))),
              value: _selected,
              items: [
                for (final AuthProvider provider
                    in Account.authProviders.values)
                  DropdownMenuItem(
                      value: provider.type, child: Text(provider.name))
              ],
              onChanged: (value) {
                setState(() => _selected = value as String);
                config.preferredLoginType = value as String;
                config.save();
                config.write(CoreConfig.defaultCoreConfig);
              }))
    ]);
  }
}
