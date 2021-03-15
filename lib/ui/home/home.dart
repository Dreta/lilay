import 'package:flutter/material.dart';
import 'package:lilay/ui/home/account.dart';
import 'package:lilay/ui/home/profile.dart';

import 'account.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(children: [
      Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Lilay', style: textTheme.headline5)),
        Divider(height: 1, thickness: 1, color: theme.dividerColor),

        // Accounts
        Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
            child: Text('ACCOUNTS', style: textTheme.subtitle2)),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Divider(height: 1, thickness: 1, color: theme.dividerColor)),
        Account(name: 'Dreta'),
        Account(name: 'DretaAlt'),

        // Profiles
        Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
            child: Text('PROFILES', style: textTheme.subtitle2)),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Divider(height: 1, thickness: 1, color: theme.dividerColor)),
        Profile(name: 'Fabric 1.16.5', modded: true),
        Profile(name: 'Vanilla 1.16.5')
      ]))
    ]);
  }
}
