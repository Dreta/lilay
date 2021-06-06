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

import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:logging/logging.dart';

import '../version_data.dart';

/// This task downloads the client file from a [VersionData]
/// and caches it accordingly.
class CoreDownloadTask {
  static const String CLIENT_PATH = 'versions/{version}/{version}.jar';

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function resultCallback;
  VersionData version;
  String workingDir;

  /// Prevent the callbacks from being called anymore.
  void disable() {
    progressCallback = (a) => {};
    errorCallback = (a) => {};
    resultCallback = (a) => {};
  }

  CoreDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.version,
      required this.workingDir});

  /// Check if the client already exist at the specified [workingDir]
  /// and that the hash matches.
  Future<bool> coreExists() async {
    File file = File(
        '$workingDir${Platform.pathSeparator}${CLIENT_PATH.replaceAll('{version}', version.id)}');
    return ((await file.exists()) &&
            (version.downloads.client.sha1.toLowerCase() ==
                sha1
                    .convert(List.from(await file.readAsBytes()))
                    .toString()
                    .toLowerCase())) &&
        (await file.length() == version.downloads.client.size);
  }

  /// Start to download the client from the download source [source].
  void start(String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the core game ${version.id}.');
    Request request = Request(
        'GET',
        Uri.parse(version.downloads.client.url
            .replaceAll(CoreConfig.DEFAULT_CORE_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();

      resp.stream.handleError((error) => errorCallback(error.toString()));

      int received = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        received += chunk.length;
        logger.fine('Received ${chunk.length} bytes of data.');
        if (resp.contentLength != null) {
          progressCallback(received / resp.contentLength!);
        }
        receivedBytes.addAll(chunk);

        if (received >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              version.downloads.client.sha1.toLowerCase()) {
            logger.severe('Client ${version.id}.jar\'s checksum is invalid.');
            errorCallback('File ${version.id}.jar\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != version.downloads.client.size) {
            logger.severe('Client ${version.id}.jar\'s size is incorrect.');
            errorCallback('File ${version.id}.jar\'s size is incorrect.');
            return;
          }

          logger.info('Saved client ${version.id}.');
          File('$workingDir${Platform.pathSeparator}${CLIENT_PATH.replaceAll('{version}', version.id)}')
              .writeAsBytes(receivedBytes);
        }
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
