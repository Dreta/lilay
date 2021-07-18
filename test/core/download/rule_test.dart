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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'rule_test.mocks.dart';

@GenerateMocks([Account, Profile])
void main() {
  group('Rule', () {
    group('Allow if a demo account and Linux is available.', () {
      test(
          'Should be applicable if account is demo, resolution is custom, and OS is Linux.',
          () {
        final Rule rule = Rule(RuleAction.allow, FeatureSet(true, null),
            OSInfo('linux', null, null));
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(
            rule.customApplicable(account, profile, 'linux', 'x86_64', '5.13'),
            true);
      });

      test(
          'Shouldn\'t be applicable if account is demo, resolution is custom, and OS is Windows.',
          () {
        final Rule rule = Rule(RuleAction.allow, FeatureSet(true, null),
            OSInfo('linux', null, null));
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(
            rule.customApplicable(account, profile, 'windows', 'x86_64', '12'),
            false);
      });

      test(
          'Shouldn\'t be applicable if account is paid, resolution isn\'t custom, and OS is Linux',
          () {
        final Rule rule = Rule(RuleAction.allow, FeatureSet(true, null),
            OSInfo('linux', null, null));
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(
            rule.customApplicable(account, profile, 'linux', 'x86_64', '5.13'),
            false);
      });
    });
  });

  group('FeatureSet', () {
    group('Requiring both a demo account and a custom resolution.', () {
      test('Should be applicable if account is demo and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is demo and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });
    });

    group('Requiring only a demo account.', () {
      test('Should be applicable if account is demo and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, null);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Should be applicable if account is demo and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, null);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, null);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, null);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });
    });

    group('Requiring only a custom resolution.', () {
      test('Should be applicable if account is demo and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(null, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is demo and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(null, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });

      test('Should be applicable if account is paid and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(null, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(null, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });
    });

    group('Requiring a demo account and no custom resolution.', () {
      test(
          'Shouldn\'t be applicable if account is demo and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, false);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Should be applicable if account is demo and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, false);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(true, false);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(true, false);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });
    });

    group('Requiring no demo account and a custom resolution.', () {
      test(
          'Shouldn\'t be applicable if account is demo and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(false, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), false);
      });

      test(
          'Shouldn\'t be applicable if account is demo and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(false, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(false);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });

      test('Should be applicable if account is paid and resolution is custom.',
          () {
        final FeatureSet feature = FeatureSet(false, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(1920);
        when(profile.resolutionHeight).thenReturn(1080);
        expect(feature.applicable(account, profile), true);
      });

      test(
          'Shouldn\'t be applicable if account is paid and resolution isn\'t custom.',
          () {
        final FeatureSet feature = FeatureSet(false, true);
        final MockAccount account = MockAccount();
        final MockProfile profile = MockProfile();
        when(account.paid).thenReturn(true);
        when(profile.resolutionWidth).thenReturn(null);
        when(profile.resolutionHeight).thenReturn(null);
        expect(feature.applicable(account, profile), false);
      });
    });
  });

  group('OSInfo', () {
    group('Requiring Windows, any architecture, and any version.', () {
      test('Should be applicable if OS is Windows.', () {
        final OSInfo os = OSInfo('windows', null, null);
        expect(os.customApplicable('windows', 'x86_64', '12'), true);
      });

      test('Shouldn\'t be applicable if OS is Linux.', () {
        final OSInfo os = OSInfo('windows', null, null);
        expect(os.customApplicable('linux', 'x86_64', '5.13'), false);
      });
    });

    group('Requiring macOS, x86_64, and any version.', () {
      test('Should be applicable if OS is macOS and arch is x86_64.', () {
        final OSInfo os = OSInfo('osx', 'x86_64', null);
        expect(os.customApplicable('osx', 'x86_64', '12'), true);
      });

      test('Shouldn\'t be applicable if OS is macOS and arch is arm64.', () {
        final OSInfo os = OSInfo('osx', 'x86_64', null);
        expect(os.customApplicable('osx', 'arm64', '12'), false);
      });

      test('Shouldn\'t be applicable if OS is Linux and arch is x86_64.', () {
        final OSInfo os = OSInfo('osx', 'x86_64', null);
        expect(os.customApplicable('linux', 'x86_64', '5.13'), false);
      });

      test('Shouldn\'t be applicable if OS is Linux and arch is arm64.', () {
        final OSInfo os = OSInfo('osx', 'x86_64', null);
        expect(os.customApplicable('linux', 'arm64', '5.13'), false);
      });
    });

    group('Requiring Windows, x86_64, and version /^10\\./', () {
      test(
          'Should be applicable if OS is Windows, arch is x86_64 and version is 10.11.',
          () {
        final OSInfo os = OSInfo('windows', 'x86_64', '^10\\.');
        expect(os.customApplicable('windows', 'x86_64', '10.11'), true);
      });

      test(
          'Shouldn\'t be applicable if OS is Linux, arch is arm64 and version is 5.13.',
          () {
        final OSInfo os = OSInfo('windows', 'x86_64', '^10\\.');
        expect(os.customApplicable('linux', 'arm64', '5.13'), false);
      });
    });
  });
}
