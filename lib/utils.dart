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
