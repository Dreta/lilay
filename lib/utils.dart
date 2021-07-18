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

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

Random random = Random();

/// Add dashes to a UUID string for parsing into a UuidValue.
String dashifyUUID(String uuid) =>
    '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}';

/// Get the default platform-dependent .minecraft directory location.
String getDefaultMinecraft() {
  if (Platform.isWindows) {
    return '${Platform.environment['APPDATA']}\\.minecraft/';
  } else if (Platform.isMacOS) {
    return '${Platform.environment['HOME']}/Library/Application Support/minecraft/';
  } else {
    return '${Platform.environment['HOME']}/.minecraft/';
  }
}

/// Get the location of the platform-dependent temporary directory location.
String getTempDirectory() {
  if (Platform.isWindows) {
    return '${Platform.environment['LOCALAPPDATA']}\\Temp/';
  } else if (Platform.isMacOS) {
    return '${Platform.environment['TMPDIR']}/';
  } else {
    return '/tmp/';
  }
}

const characters =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

/// Generate a random string.
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));

/// Get all locally available version manifests.
Stream<VersionData> getAvailableVersions(String workingDir) async* {
  final Logger logger = GetIt.I.get<Logger>();
  Directory versions =
      Directory('${workingDir}${Platform.pathSeparator}versions');
  await for (FileSystemEntity directory in versions.list()) {
    if (directory is Directory) {
      File data = File(
          join(directory.absolute.path, '${basename(directory.path)}.json'));
      if (await data.exists()) {
        try {
          Map<String, dynamic> json = jsonDecode(await data.readAsString());
          if (json.containsKey('type') &&
              json['type'].toString().contains('old')) {
            // Skip
            continue;
          }
          if (json['releaseTime'] != null) {
            DateTime releaseTime = DateTime.parse(json['releaseTime']);
            if (releaseTime.compareTo(
                    GetIt.I.get<DateTime>(instanceName: 'minimumSupport')) <
                0) {
              continue;
            }
          }
          yield VersionData.fromJson(json);
        } catch (e) {
          // Ignore parsing errors for the version data - we will discard this version
          logger.severe(
              'Failed to parse the version data in ${directory.absolute.path}: $e.');
        }
      }
    }
  }
}

/// Get all locally available version infos.
Stream<VersionInfo> getAvailableVersionInfos(String workingDir) async* {
  await for (VersionData version in getAvailableVersions(workingDir)) {
    yield VersionInfo(
        version.id, version.type, '', version.time, version.releaseTime);
  }
}

/// Get the operating system name, in Minecraft's fashion.
///
/// Windows: windows
/// macOS: osx
/// Linux: linux
String getOSName() {
  if (Platform.isWindows) {
    return 'windows';
  } else if (Platform.isMacOS) {
    return 'osx';
  } else if (Platform.isLinux) {
    return 'linux';
  }
  throw 'Unsupported operating system';
}

/// Detect the path of the installed Java based on the
/// operating system.
///
/// Returns an empty string if Java is unavailable.
Future<String> detectJavaInstallation() async {
  if (Platform.environment.containsKey('JAVA_HOME')) {
    // Use the JAVA_HOME environment variable when available.
    String javaHome = Platform.environment['JAVA_HOME']!;
    File javaExec;
    if (javaHome.endsWith('/') || javaHome.endsWith('\\')) {
      javaExec = File(
          '${javaHome}bin${Platform.pathSeparator}java${Platform.isWindows ? '.exe' : ''}');
    } else {
      javaExec = File(
          '$javaHome${Platform.pathSeparator}bin${Platform.pathSeparator}java${Platform.isWindows ? '.exe' : ''}');
    }
    if (await javaExec.exists()) return javaExec.absolute.path;
  }

  if (Platform.isLinux) {
    ProcessResult result = await Process.run('which', ['java']);
    if (result.exitCode == 0) return result.stdout.toString().trim();
    return '';
  } else if (Platform.isMacOS) {
    ProcessResult result = await Process.run('/usr/libexec/java_home', []);
    if (result.exitCode == 0 &&
        !result.stdout.toString().contains('Unable') /* Unable to locate */) {
      String path = result.stdout.toString().trim();
      if (path.endsWith(Platform.pathSeparator)) {
        return '${path}bin${Platform.pathSeparator}java';
      }
      return '$path${Platform.pathSeparator}bin${Platform.pathSeparator}java';
    }
    return '';
  } else if (Platform.isWindows) {
    // Need testing
    ProcessResult result = await Process.run('where', ['java']);
    if (result.exitCode == 0) return result.stdout.toString().trim();
    return '';
  }
  return '';
}
