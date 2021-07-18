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
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:lilay/core/auth/microsoft/microsoft_account.dart';

/// MicrosoftDialog displays information regarding how to
/// log into a Microsoft account.
class MicrosoftDialog extends StatefulWidget {
  final Function(String) openUrl;
  final Future<void> Function(String) loginCallback;

  const MicrosoftDialog({required this.openUrl, required this.loginCallback});

  static void display(BuildContext context, Function(String) openUrl,
      Future<void> Function(String) loginCallback) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) =>
            MicrosoftDialog(openUrl: openUrl, loginCallback: loginCallback),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  _MicrosoftDialogState createState() =>
      _MicrosoftDialogState(openUrl: openUrl, loginCallback: loginCallback);
}

class _MicrosoftDialogState extends State<MicrosoftDialog> {
  static final String oauth2url = 'https://login.live.com/oauth20_authorize.srf'
      '?client_id=${MicrosoftAccount.CLIENT_ID}'
      '&response_type=code'
      '&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL'
      '&redirect_uri=${Uri.encodeComponent(MicrosoftAccount.REDIRECT_URI)}';

  bool _loggingIn = false;
  DisplayState _display = DisplayState.tutorial;
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _link = TextEditingController();

  final Function(String) openUrl;
  final Future<void> Function(String) loginCallback;

  _MicrosoftDialogState({required this.openUrl, required this.loginCallback});

  void _login(String link) async {
    if (_form.currentState!.validate()) {
      setState(() => _loggingIn = true);
      await loginCallback(link);
      Navigator.pop(context);
      setState(() => _loggingIn = false);
    }
  }

  Widget _buildLinkField(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        enabled: !_loggingIn,
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _link,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'A link is required.';
          }

          Uri uri;
          try {
            uri = Uri.parse(value);
          } catch (e) {
            return 'Invalid link.';
          }

          if (!value.startsWith(MicrosoftAccount.REDIRECT_URI) ||
              !uri.queryParameters.containsKey('code')) {
            return 'The link is incorrect. Please check if you are on an empty page.';
          }
        },
        onFieldSubmitted: (value) => _login(value),
        decoration: InputDecoration(
            labelText: 'Code Link',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  Widget _buildSubmitButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton(
        onPressed: _loggingIn ? null : () => _login(_link.text),
        style: theme.elevatedButtonTheme.style,
        child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Text('Login')));
  }

  Widget _buildContinueButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton(
        onPressed: () {
          openUrl(oauth2url);
          setState(() => _display = DisplayState.code);
        },
        style: theme.elevatedButtonTheme.style,
        child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Text('Continue')));
  }

  Widget _buildTutorial(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tutorial - Read Carefully', style: textTheme.subtitle2),
          Text(
              '1. You will see a login page or an empty page after clicking \'Continue\'.'),
          Text('2. If you see an empty page, proceed to step 5.'),
          Text('3. If you see a login page, login to your Microsoft account.'),
          Text('4. After logging in, you will see an empty page.'),
          Text('5. Copy the link of that empty page, and paste it below.')
        ]);
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Form(
            key: _form,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLinkField(context),
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildSubmitButton(context))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Dialog(
        child: Container(
            width: 512,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loggingIn) LinearProgressIndicator(),
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text('Login with Microsoft',
                                    style: textTheme.headline6)),
                            _buildTutorial(context),
                            if (_display == DisplayState.tutorial)
                              Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _buildContinueButton(context))
                            else
                              Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: _buildForm(context))
                          ]))
                ])));
  }
}

enum DisplayState { tutorial, code }
