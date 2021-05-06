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

import 'package:lilay/core/auth/account.dart';

import '../../rule.dart';

/// Represents argument(s) in the version manifest file.
/// The arguments can either be a plain argument or ruled.
class Argument {
  String value;
  List<Rule> rules;

  Argument({required this.value, required this.rules});

  bool applicable(Account account) {
    // Make this argument always applicable if the rules are empty.
    bool applicability = rules.isEmpty;

    for (Rule rule in rules) {
      if (rule.action == RuleAction.allow) {
        if (rule.applicable(account)) {
          applicability = true;
        } else {
          return false;
        }
      } else {
        if (rule.applicable(account)) {
          return false;
        }
        applicability = true;
      }
    }

    return applicability;
  }
}
