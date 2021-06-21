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

import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/version/library/artifact.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/utils.dart';

import '../../rule.dart';

/// Represents argument(s) in the version manifest file.
/// The arguments can either be a plain argument or ruled.
class Argument {
  List<dynamic> value;
  List<Rule> rules;

  Argument({required this.value, required this.rules});

  List<String> contextualValue(
      Account account, Profile profile, CoreConfig config, VersionData data,
      [String natives = '']) {
    List<String> classpaths = [];
    for (Library library in data.libraries) {
      if (Rule.multiRulesApplicable(library.rules, account, profile)) {
        if (library.downloads == null) {
          classpaths.add(
              '${Artifact(library.name).path('${config.workingDirectory}${Platform.pathSeparator}libraries')}');
        } else if (library.downloads!.artifact != null) {
          classpaths.add(
              '${config.workingDirectory}${Platform.pathSeparator}libraries${Platform.pathSeparator}${library.downloads!.artifact!.path}');
        }
      }
    }
    classpaths.add(
        '${config.workingDirectory}${Platform.pathSeparator}versions${Platform.pathSeparator}${data.id}${Platform.pathSeparator}${data.id}.jar');

    return List.from(value.map((s) {
      return s
          .toString()
          .replaceAll('\${auth_player_name}', account.profileName)
          .replaceAll('\${auth_user_name}', account.profileName)
          .replaceAll('\${version_name}', data.id)
          .replaceAll('\${game_directory}',
              profile.gameDirectory ?? getDefaultMinecraft())
          .replaceAll('\${assets_root}',
              '${config.workingDirectory}${Platform.pathSeparator}assets')
          .replaceAll('\${game_assets',
              '${config.workingDirectory}${Platform.pathSeparator}assets')
          .replaceAll('\${assets_index_name}', data.assets)
          .replaceAll('\${auth_uuid}', account.uuid.replaceAll('-', ''))
          .replaceAll('\${auth_access_token}', account.accessToken)
          .replaceAll('\${user_type}',
              account.type == 'microsoft' ? 'microsoft' : 'mojang')
          .replaceAll('\${version_type}',
              data.type.toString().replaceAll('VersionType.', ''))
          .replaceAll('\${user_properties}', '{}')
          .replaceAll('\${auth_session}', account.accessToken)
          .replaceAll(
              '\${resolution_width}',
              profile.resolutionWidth == null
                  ? '1024'
                  : profile.resolutionWidth.toString())
          .replaceAll(
              '\${resolution_height}',
              profile.resolutionHeight == null
                  ? '576'
                  : profile.resolutionHeight.toString())
          .replaceAll('\${natives_directory}', natives)
          .replaceAll('\${launcher_name}', 'Lilay')
          .replaceAll('\${launcher_version}',
              GetIt.I.get<String>(instanceName: 'version'))
          .replaceAll('\${classpath}', classpaths.join(':'));
    }));
  }

  bool applicable(Account account, Profile profile) =>
      Rule.multiRulesApplicable(rules, account, profile);
}
