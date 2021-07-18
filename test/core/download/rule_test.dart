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

import 'package:flutter_test/flutter_test.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'rule_test.mocks.dart';

@GenerateMocks([Account, Profile])
void main() {
  group('Rule', () {}); // TODO

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
    // TODO
    group('Requiring Windows, any architecture, and any version.', () {});

    group('Requiring macOS, x86_64, and any version.', () {});

    group('Requiring Linux, x86, and any version.', () {});

    group('Requiring Windows, x86_64, and version /^10./', () {});
  });
}