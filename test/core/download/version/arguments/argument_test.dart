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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/version/arguments/argument.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/lib_download_info.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'argument_test.mocks.dart';

const String PROFILE_NAME = 'Dreta';
const String ID = '2.0';
const String GAME_DIRECTORY = '~/.minecraft';
const String WORKING_DIRECTORY = '~/.minecraft';
const String ASSETS = '2.0';
const String UUID = '6cc9ba8e88034534a3d2ade79263cb1e';
const String ACCESS_TOKEN = 'lilaytest';
const String TYPE = 'microsoft';
const VersionType VERSION_TYPE = VersionType.pending;
const int RESOLUTION_WIDTH = 3840;
const int RESOLUTION_HEIGHT = 2160;
const String NATIVES = '/tmp/lilayntvs-6cc9ba8e';

@GenerateMocks([Account, Profile, CoreConfig, VersionData])
void main() {
  group('Argument', () {
    GetIt.I.registerSingleton<String>('1.0', instanceName: 'version');

    test('Contextual value should correctly replace auth_player_name.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${auth_player_name}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          PROFILE_NAME);
    });

    test('Contextual value should correctly replace auth_user_name.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${auth_user_name}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          PROFILE_NAME);
    });

    test('Contextual value should correctly replace version_name.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${version_name}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0], ID);
    });

    test('Contextual value should correctly replace game_directory.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${game_directory}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          GAME_DIRECTORY);
    });

    test('Contextual value should correctly replace assets_root.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument = Argument(value: ['\${assets_root}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          '$WORKING_DIRECTORY${Platform.pathSeparator}assets');
    });

    test('Contextual value should correctly replace game_assets.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument = Argument(value: ['\${game_assets}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          '$WORKING_DIRECTORY${Platform.pathSeparator}assets');
    });

    test('Contextual value should correctly replace assets_index_name.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${assets_index_name}'], rules: []);
      expect(
          argument.contextualValue(account, profile, config, data)[0], ASSETS);
    });

    test('Contextual value should correctly replace auth_uuid.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument = Argument(value: ['\${auth_uuid}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0], UUID);
    });

    test('Contextual value should correctly replace auth_access_token.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${auth_access_token}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          ACCESS_TOKEN);
    });

    test('Contextual value should correctly replace version_type.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${version_type}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          'pending');
    });

    test('Contextual value should correctly replace auth_session.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${auth_session}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          ACCESS_TOKEN);
    });

    test('Contextual value should correctly replace resolution_width.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${resolution_width}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          '$RESOLUTION_WIDTH');
    });

    test('Contextual value should correctly replace resolution_height.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${resolution_height}'], rules: []);
      expect(argument.contextualValue(account, profile, config, data)[0],
          '$RESOLUTION_HEIGHT');
    });

    test('Contextual value should correctly replace natives_directory.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument =
          Argument(value: ['\${natives_directory}'], rules: []);
      expect(
          argument.contextualValue(account, profile, config, data, NATIVES)[0],
          NATIVES);
    });

    test('Contextual value should correctly replace classpath.', () {
      final MockAccount account = MockAccount();
      final MockProfile profile = MockProfile();
      final MockCoreConfig config = MockCoreConfig();
      final MockVersionData data = MockVersionData();
      mockAll(account, profile, config, data);

      final Argument argument = Argument(value: ['\${classpath}'], rules: []);
      String sep = Platform.pathSeparator;
      List<String> classpaths = argument
          .contextualValue(account, profile, config, data)[0]
          .replaceAll(sep, '/')
          .split(':');
      expect(
          classpaths.contains(
                  '$WORKING_DIRECTORY/libraries/dev/dreta/lilay-lib/1.0/lilay-lib-1.0.jar') &&
              classpaths.contains(
                  '$WORKING_DIRECTORY/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar'),
          true);
    });
  });
}

void mockAll(MockAccount account, MockProfile profile, MockCoreConfig config,
    MockVersionData data) {
  when(account.profileName).thenReturn(PROFILE_NAME);
  when(data.id).thenReturn(ID);
  when(profile.gameDirectory).thenReturn(GAME_DIRECTORY);
  when(config.workingDirectory).thenReturn(WORKING_DIRECTORY);
  when(data.assets).thenReturn(ASSETS);
  when(account.uuid).thenReturn(UUID);
  when(account.accessToken).thenReturn(ACCESS_TOKEN);
  when(account.type).thenReturn(TYPE);
  when(data.type).thenReturn(VERSION_TYPE);
  when(profile.resolutionWidth).thenReturn(RESOLUTION_WIDTH);
  when(profile.resolutionHeight).thenReturn(RESOLUTION_HEIGHT);

  List<Library> libraries = [];
  libraries.add(Library(null, 'dev.dreta:lilay:1.0', null, null, null));
  libraries.add(Library(
      LibDownloadInfo(
          FriendlyDownload('dev/dreta/lilay-lib/1.0/lilay-lib-1.0.jar',
              '062d0e3bfafabb22903e0afe00d0d535239cf179', 0x6cc9ba8e, ''),
          null),
      'dev:dreta:lilay-lib:1.0',
      null,
      null,
      null));
  when(data.libraries).thenReturn(libraries);
}
