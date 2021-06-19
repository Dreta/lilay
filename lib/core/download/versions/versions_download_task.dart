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
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:logging/logging.dart';

class VersionsDownloadTask extends DownloadTask<void, VersionManifest> {
  static const String MANIFEST_PATH = 'versions/version_manifest_v2.json';

  VersionsDownloadTask({required String source, required String workingDir})
      : super(source: source, dependency: null, workingDir: workingDir);

  /// Check if a version manifest already exist at the specified [workingDir].
  @override
  Future<bool> get tryLoadCache async {
    try {
      // We will not load the cache here because we always want to download
      // a new version manifest.
      return File('$workingDir${Platform.pathSeparator}$MANIFEST_PATH')
          .exists();
    } catch (e) {
      exceptionPhase = Phase.loadCache;
      exception = e;
      notify();
      // Use the cache when we must
      File file = File('$workingDir${Platform.pathSeparator}$MANIFEST_PATH');
      if (await file.exists()) {
        result =
            VersionManifest.fromJson(jsonDecode(await file.readAsString()));
        return true;
      }
      return false;
    }
  }

  /// Start to download the version manifest from the download source [source].
  @override
  Future<void> download() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the versions manifest.');
    Request request =
        Request('GET', Uri.parse(source + VersionManifest.LOCATION));
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
          // We're done!
          String json = utf8.decode(receivedBytes);
          result = VersionManifest.fromJson(jsonDecode(json));
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
      File local = File('$workingDir${Platform.pathSeparator}$MANIFEST_PATH');
      local.parent.create(recursive: true);
      local.writeAsString(jsonEncode(result!.toJson()));
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
