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

class Account extends StatelessWidget {
  final String name;

  const Account({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton(
        tooltip: 'Account ' + name,
        offset: const Offset(50, 0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                  child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh'),
                      minLeadingWidth: 20)),
              const PopupMenuItem(
                  child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                      minLeadingWidth: 20))
            ],
        child: ListTile(
            leading: Icon(Icons.account_circle, color: theme.accentColor),
            title: Text(name),
            minLeadingWidth: 20));
  }
}
