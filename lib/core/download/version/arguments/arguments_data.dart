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

import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/arguments/argument.dart';

part 'arguments_data.g.dart';

/// Represents the provided argument information in the version manifest.
///
/// Might not be available. In the case that only [minecraftArguments] is
/// available, the default set of JVM arguments should be used.
@JsonSerializable(explicitToJson: true)
class ArgumentsData {
  List<dynamic>?
      game; // We must use dynamic here because the argument can either be a string or a ruled argument
  List<dynamic>? jvm;

  ArgumentsData(List<dynamic>? game, List<dynamic>? jvm)
      : this.game = game,
        this.jvm = jvm;

  /// Get the game arguments parsed into a list of [Argument]s.
  List<Argument> get gameParsed {
    List<Argument> arguments = [];
    for (dynamic i in (game ?? [])) {
      if (i is String) {
        // If this is a plain argument
        arguments.add(Argument(value: [i], rules: [])); // Add without rules
      } else if (i is List) {
        arguments.add(Argument(value: i, rules: []));
      } else if (i is Map) {
        // If this is a JSON object (rules: [...], value: ...)
        List<Rule> rules = [];
        if (i.containsKey('rules')) {
          // If we do have rules (will always execute [hopefully])
          for (Map<String, dynamic> rule in i['rules']) {
            rules.add(Rule.fromJson(rule)); // Parse the rules and add them
          }
        }
        if (i['value'] is String) {
          arguments.add(Argument(value: [i['value']], rules: rules));
        } else {
          arguments
              .add(Argument(value: i['value'], rules: rules)); // Add with rules
        }
      }
    }
    return arguments;
  }

  /// Get the JVM arguments parsed into a list of [Argument]s.
  List<Argument> get jvmParsed {
    List<Argument> arguments = [];
    for (dynamic i in (jvm ?? [])) {
      if (i is String) {
        arguments.add(Argument(value: [i], rules: []));
      } else if (i is List) {
        arguments.add(Argument(value: i, rules: []));
      } else if (i is Map) {
        List<Rule> rules = [];
        if (i.containsKey('rules')) {
          for (Map<String, dynamic> rule in i['rules']) {
            rules.add(Rule.fromJson(rule));
          }
        }
        if (i['value'] is String) {
          arguments.add(Argument(value: [i['value']], rules: rules));
        } else {
          arguments.add(Argument(value: i['value'], rules: rules));
        }
      }
    }
    return arguments;
  }

  Map<String, dynamic> toJson() => _$ArgumentsDataToJson(this);

  factory ArgumentsData.fromJson(Map<String, dynamic> json) =>
      _$ArgumentsDataFromJson(json);
}
