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

import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:logging/logging.dart';

import 'version_data.dart';

/// Download the metadata JSON file of the [version]. The downloaded file
/// will be saved automatically.
///
/// This is a SHALLOW download. The associated assets, client, libraries etc.
/// are NOT downloaded within this task.
class VersionDownloadTask extends DownloadTask<VersionInfo, VersionData> {
  static const String VERSION_PATH = 'versions/{version}/{version}.json';

  VersionDownloadTask(
      {required String source,
      required VersionInfo dependency,
      required String workingDir})
      : super(source: source, dependency: dependency, workingDir: workingDir);

  /// Check if the version metadata already exist at the specified [workingDir].
  @override
  Future<bool> get tryLoadCache async {
    try {
      File file = File(
          '$workingDir${Platform.pathSeparator}${VERSION_PATH.replaceAll('{version}', dependency.id)}');
      if (await file.exists()) {
        result = VersionData.fromJson(jsonDecode(await file.readAsString()));
        progress = 1;
        return true;
      }
      return false;
    } catch (e) {
      exceptionPhase = Phase.loadCache;
      exception = e;
      notify();
      return false;
    }
  }

  @override
  Future<void> download() async {
    Logger logger = GetIt.I.get<Logger>();
    logger
        .info('Downloading the version manifest for version ${dependency.id}.');
    Request request = Request(
        'GET',
        Uri.parse(
            dependency.url.replaceAll(CoreConfig.DEFAULT_META_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();

      resp.stream.handleError((error) {
        exceptionPhase = Phase.download;
        exception = error;
        notify();
      });

      int received = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        logger.fine('Received ${chunk.length} bytes of data.');
        received += chunk.length;
        progress = received / resp.contentLength!;
        notify();
        receivedBytes.addAll(chunk);

        if (finished) {
          String json = utf8.decode(receivedBytes);
          result = VersionData.fromJson(jsonDecode(json));
          notify();
        }
      });
    } catch (e) {
      exceptionPhase = Phase.download;
      exception = e;
      notify();
    }
  }

  @override
  Future<void> save() async {
    try {
      // FIXME The data is not saved.
      // Error: Unhandled Exception: FileSystemException: Cannot open file, path = '...' (OS Error: No such file or directory, errno = 2)
      File local = File(
          '$workingDir${Platform.pathSeparator}${VERSION_PATH.replaceAll('{version}', dependency.id)}');
      local.parent.create(recursive: true);
      local.writeAsString(jsonEncode(result!.toJson()));
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
