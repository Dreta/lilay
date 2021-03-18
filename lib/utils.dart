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
