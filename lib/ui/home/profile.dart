import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String name;
  final bool modded;

  const Profile({
    required this.name,
    this.modded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        leading: Icon(modded ? Icons.hardware : Icons.sports_esports,
            color: theme.accentColor),
        title: Text(name),
        minLeadingWidth: 20);
  }
}
