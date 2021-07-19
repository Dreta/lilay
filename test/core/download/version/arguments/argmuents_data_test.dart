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

import 'package:flutter_test/flutter_test.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/arguments/argument.dart';
import 'package:lilay/core/download/version/arguments/arguments_data.dart';

void main() {
  group('ArgumentsData', () {
    group('gameParsed', () {
      test('gameParsed should correctly parse a raw game argument.', () {
        final ArgumentsData args = ArgumentsData(['game'], null);
        expect(args.gameParsed[0].value[0], 'game');
      });

      test('gameParsed should correctly parse multiple raw game arguments.',
          () {
        final ArgumentsData args = ArgumentsData([
          'game',
          ['arg', 'argument']
        ], null);
        List<Argument> parsed = args.gameParsed;
        expect(parsed[0].value[0], 'game');
        expect(parsed[1].value[0], 'arg');
        expect(parsed[1].value[1], 'argument');
      });

      test('gameParsed should correctly parse a game argument with rules.', () {
        final ArgumentsData args = ArgumentsData([
          {
            'rules': [
              {
                'action': 'allow',
                'features': {'is_demo_user': true}
              }
            ],
            'value': '--demo'
          }
        ], null);
        List<Argument> parsed = args.gameParsed;
        expect(parsed[0].value[0], '--demo');
        expect(parsed[0].rules[0].action, RuleAction.allow);
        expect(parsed[0].rules[0].features!.isDemoUser, true);
      });

      test(
          'gameParsed should correctly parse multiple game arguments with rules.',
          () {
        final ArgumentsData args = ArgumentsData([
          {
            'rules': [
              {
                'action': 'allow',
                'features': {'is_demo_user': true}
              }
            ],
            'value': '--demo'
          },
          {
            'rules': [
              {
                'action': 'allow',
                'features': {'has_custom_resolution': true}
              }
            ],
            'value': [
              '--width',
              '\${resolution_width}',
              '--height',
              '\${resolution_height}'
            ]
          }
        ], null);
        List<Argument> parsed = args.gameParsed;
        expect(parsed[0].value[0], '--demo');
        expect(parsed[0].rules[0].action, RuleAction.allow);
        expect(parsed[0].rules[0].features!.isDemoUser, true);
        expect(parsed[1].value[0], '--width');
        expect(parsed[1].value[1], '\${resolution_width}');
        expect(parsed[1].value[2], '--height');
        expect(parsed[1].value[3], '\${resolution_height}');
        expect(parsed[1].rules[0].action, RuleAction.allow);
        expect(parsed[1].rules[0].features!.hasCustomResolution, true);
      });
    });

    group('jvmParsed', () {
      test('jvmParsed should correctly parse a raw JVM argument.', () {
        final ArgumentsData args = ArgumentsData(null, ['jvm']);
        expect(args.jvmParsed[0].value[0], 'jvm');
      });

      test('jvmParsed should correctly parse multiple raw JVM arguments.', () {
        final ArgumentsData args = ArgumentsData(null, [
          'jvm',
          ['arg', 'argument']
        ]);
        List<Argument> parsed = args.jvmParsed;
        expect(parsed[0].value[0], 'jvm');
        expect(parsed[1].value[0], 'arg');
        expect(parsed[1].value[1], 'argument');
      });

      test('jvmParsed should correctly parse a JVM argument with rules.', () {
        final ArgumentsData args = ArgumentsData(null, [
          {
            'rules': [
              {
                'action': 'allow',
                'os': {'name': 'windows'}
              }
            ],
            'value':
                '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump'
          }
        ]);
        List<Argument> parsed = args.jvmParsed;
        expect(parsed[0].value[0],
            '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump');
        expect(parsed[0].rules[0].action, RuleAction.allow);
        expect(parsed[0].rules[0].os!.name, 'windows');
      });

      test(
          'jvmParsed should correctly parse multiple JVM arguments with rules.',
          () {
        final ArgumentsData args = ArgumentsData(null, [
          {
            'rules': [
              {
                'action': 'allow',
                'os': {'name': 'windows'}
              }
            ],
            'value':
                '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump'
          },
          {
            'rules': [
              {
                'action': 'allow',
                'os': {'name': 'windows', 'version': '^10\\.'}
              }
            ],
            'value': ['-Dos.name=Windows 10', '-Dos.version=10.0']
          }
        ]);
        List<Argument> parsed = args.jvmParsed;
        expect(parsed[0].value[0],
            '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump');
        expect(parsed[0].rules[0].action, RuleAction.allow);
        expect(parsed[0].rules[0].os!.name, 'windows');
        expect(parsed[1].value[0], '-Dos.name=Windows 10');
        expect(parsed[1].value[1], '-Dos.version=10.0');
        expect(parsed[1].rules[0].action, RuleAction.allow);
        expect(parsed[1].rules[0].os!.name, 'windows');
        expect(parsed[1].rules[0].os!.version, '^10\\.');
      });
    });
  });
}
