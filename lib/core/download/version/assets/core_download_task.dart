/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later dependency.
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
import 'package:lilay/core/download/task.dart';
import 'package:logging/logging.dart';

import '../version_data.dart';

/// This task downloads the client file from a [VersionData]
/// and caches it accordingly.
class CoreDownloadTask extends DownloadTask<VersionData, List<int>> {
  static const String CLIENT_PATH = 'versions/{version}/{version}.jar';

  CoreDownloadTask(
      {required String source,
      required VersionData dependency,
      required String workingDir})
      : super(source: source, dependency: dependency, workingDir: workingDir);

  /// Check if the client already exist at the specified [workingDir]
  /// and that the hash matches.
  @override
  Future<bool> get tryLoadCache async {
    try {
      File file = File(
          '$workingDir${Platform.pathSeparator}${CLIENT_PATH.replaceAll('{version}', dependency.id)}');
      bool available = ((await file.exists()) &&
              (dependency.downloads.client.sha1.toLowerCase() ==
                  sha1
                      .convert(List.from(await file.readAsBytes()))
                      .toString()
                      .toLowerCase())) &&
          (await file.length() == dependency.downloads.client.size);
      if (available) {
        result = await file.readAsBytes();
      }
      return available;
    } catch (e) {
      exceptionPhase = Phase.loadCache;
      exception = e;
      notify();
      return false;
    }
  }

  /// Start to download the client from the download source [source].
  @override
  Future<void> download() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the core game ${dependency.id}.');
    Request request = Request(
        'GET',
        Uri.parse(dependency.downloads.client.url
            .replaceAll(CoreConfig.DEFAULT_CORE_SOURCE, source)));
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
        received += chunk.length;
        logger.fine('Received ${chunk.length} bytes of data.');
        progress = received / resp.contentLength!;
        notify();
        receivedBytes.addAll(chunk);

        if (received >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              dependency.downloads.client.sha1.toLowerCase()) {
            logger
                .severe('Client ${dependency.id}.jar\'s checksum is invalid.');
            exception =
                Exception('File ${dependency.id}.jar\'s checksum is invalid.');
            notify();
            return;
          }

          if (receivedBytes.length != dependency.downloads.client.size) {
            logger.severe('Client ${dependency.id}.jar\'s size is incorrect.');
            exception =
                Exception('File ${dependency.id}.jar\'s size is incorrect.');
            notify();
            return;
          }

          result = receivedBytes;
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
      File('$workingDir${Platform.pathSeparator}${CLIENT_PATH.replaceAll('{version}', dependency.id)}')
          .writeAsBytes(result!);
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
