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
Future<String?> detectJavaInstallation() async {
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
    return null;
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
    return null;
  } else if (Platform.isWindows) {
    // Need testing
    ProcessResult result = await Process.run('where', ['java']);
    if (result.exitCode == 0) return result.stdout.toString().trim();
    return null;
  }
  return null;
}
