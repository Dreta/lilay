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

String dashifyUUID(String uuid) =>
    uuid.substring(0, 8) +
    '-' +
    uuid.substring(8, 12) +
    '-' +
    uuid.substring(12, 16) +
    '-' +
    uuid.substring(16, 20) +
        '-' +
        uuid.substring(20);

String getDefaultMinecraft() {
  if (Platform.isWindows) {
    return '${Platform.environment['APPDATA']}\\.minecraft/';
  } else if (Platform.isMacOS) {
    return '${Platform.environment['HOME']}/Library/Application Support/minecraft/';
  } else if (Platform.isLinux) {
    return '${Platform.environment['HOME']}/.minecraft/';
  }
  throw "Incompatible platform";
}
