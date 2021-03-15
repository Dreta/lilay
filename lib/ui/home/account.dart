import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  final String name;

  const Account({required this.name}) : assert(name != null);

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
