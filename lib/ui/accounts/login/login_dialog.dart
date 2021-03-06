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
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/auth/auth_provider.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatefulWidget {
  final Function(Account) _addAccount;

  LoginDialog({required Function(Account) onAddAccount})
      : _addAccount = onAddAccount;

  static void display(BuildContext context, Function(Account) onAddAccount) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => LoginDialog(onAddAccount: onAddAccount),
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400));
  }

  @override
  _LoginDialogState createState() =>
      _LoginDialogState(onAddAccount: _addAccount);
}

class _LoginDialogState extends State<LoginDialog> {
  final Function(Account) _addAccount;

  late String _selectedAuthProvider;
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _loggingIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedAuthProvider = Provider.of<CoreConfig>(context).preferredLoginType;
  }

  _LoginDialogState({required Function(Account) onAddAccount})
      : _addAccount = onAddAccount;

  @override
  void dispose() {
    super.dispose();
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
  }

  /// Log the user in with the input values.
  void _login(AuthProvider selected) {
    if (_form.currentState!.validate()) {
      setState(() => _loggingIn = true);
      final String? username =
          selected.useManualAuthentication ? null : _username.value.text;
      final String? password =
          (selected.useManualAuthentication || !selected.requiresPassword)
              ? null
              : _password.value.text;
      final AuthProvider provider =
          Account.authProviders[_selectedAuthProvider]!;

      // Login the user
      Logger logger = GetIt.I.get<Logger>();
      logger.info(
          'Logging to the account $username with authentication provider ${selected.name}.');
      Client client = Client();
      provider.login(context, username, password, (account) {
        Navigator.pop(context); // Close the dialog
        logger.info('Successfully logged in to the account $username.');
        _addAccount(account); // Allow the account to be added
        setState(() {
          _loggingIn = false;
        });
        client.close();
      }, (error) {
        logger.severe('Failed to login to the account $username: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $error'), duration: Duration(seconds: 3)));
        Navigator.pop(context);
        client.close();
      }, client);
    }
  }

  /// Create the username input field
  Widget _buildUsernameField(BuildContext context, AuthProvider selected) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        enabled: !_loggingIn,
        // Disable the input field if we are logging in
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _username,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '${selected.canUseEmail ? 'Email / Username' : 'Username'} is required.';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) {
          if (selected.requiresPassword) {
            FocusScope.of(context).requestFocus(_passwordFocus);
          }
        },
        decoration: InputDecoration(
            labelText: selected.canUseEmail ? 'Email / Username' : 'Username',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the password input field
  Widget _buildPasswordField(BuildContext context, AuthProvider selected) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
        enabled: !_loggingIn,
        cursorColor: theme.textSelectionTheme.cursorColor,
        controller: _password,
        focusNode: _passwordFocus,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required.';
          }
          return null;
        },
        onFieldSubmitted: (value) => _login(selected),
        decoration: InputDecoration(
            labelText: 'Password',
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor))));
  }

  /// Create the account type dropdown
  Widget _buildAccountTypeDropdown(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Theme(
        child: DropdownButtonFormField(
            decoration: InputDecoration(
                labelText: 'Account Type',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor))),
            value: _selectedAuthProvider,
            items: [
              for (final AuthProvider provider in Account.authProviders.values)
                DropdownMenuItem(
                    value: provider.type, child: Text(provider.name))
            ],
            onChanged:
                _loggingIn // Disable the dropdown menu if we are logging in
                    ? null
                    : (value) {
                        setState(() {
                          _selectedAuthProvider = value as String;
                        });
                      }),
        data: Theme.of(context)
            .copyWith(canvasColor: theme.dialogBackgroundColor));
  }

  /// Create the submit button
  Widget _buildSubmitButton(BuildContext context, AuthProvider selected) {
    final ThemeData theme = Theme.of(context);
    return Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
        child: OverflowBar(
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            overflowDirection: VerticalDirection.down,
            overflowSpacing: 0,
            children: [
              ElevatedButton(
                  onPressed:
                      _loggingIn // Disable the button if we are logging in
                          ? null
                          : () => _login(selected),
                  style: theme.elevatedButtonTheme.style,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: Text(selected.useManualAuthentication
                          ? 'Continue'
                          : 'Login')))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final AuthProvider selected = Account.authProviders[_selectedAuthProvider]!;

    final List<Widget> fields = [];
    if (!selected.useManualAuthentication) {
      fields.add(_buildUsernameField(context, selected));

      if (selected.requiresPassword) {
        fields.add(_buildPasswordField(context, selected));
      }
    }

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
                                child:
                                    Text('Login', style: textTheme.headline6)),
                            Form(
                                key: _form,
                                child: Column(children: [
                                  // This the the dropdown menu for account type selection
                                  _buildAccountTypeDropdown(context),
                                  // These are the email/password fields.
                                  for (Widget widget in fields) widget,
                                  // This is the submit button.
                                  _buildSubmitButton(context, selected)
                                ]))
                          ]))
                ])));
  }
}
