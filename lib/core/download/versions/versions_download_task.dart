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
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:logging/logging.dart';

class VersionsDownloadTask {
  static const String MANIFEST_PATH = "versions/version_manifest_v2.json";

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function(VersionManifest) resultCallback;
  String workingDir;

  VersionsDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.workingDir});

  /// Check if a version manifest already exist at the specified [workingDir].
  Future<bool> manifestExists() async {
    return File('$workingDir${Platform.pathSeparator}$MANIFEST_PATH').exists();
  }

  /// Prevent the callbacks from being called anymore.
  void disable() {
    progressCallback = (a) => {};
    errorCallback = (a) => {};
    resultCallback = (a) => {};
  }

  /// Start to download the version manifest from the download source [source].
  void start(String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the versions manifest.');
    Request request =
        Request('GET', Uri.parse(source + VersionManifest.LOCATION));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();

      resp.stream.handleError((error) => errorCallback(error.toString()));

      int received = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        logger.fine('Received ${chunk.length} bytes of data.');
        received += chunk.length;
        if (resp.contentLength != null) {
          progressCallback(received / resp.contentLength!);
        }
        receivedBytes.addAll(chunk);

        if (received >= resp.contentLength!) {
          // We're done!
          String json = utf8.decode(receivedBytes);
          VersionManifest manifest = VersionManifest.fromJson(jsonDecode(json));

          logger.info('Saved the version manifest.');
          // Cache the version manifest locally
          File local =
              File('$workingDir${Platform.pathSeparator}$MANIFEST_PATH');
          local.writeAsString(json);

          resultCallback(manifest);
        }
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
