/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
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
import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/download/assets/asset.dart';
import 'package:lilay/core/download/task.dart';
import 'package:logging/logging.dart';

/// This task downloads an individual [Asset].
class AssetDownloadTask extends DownloadTask<Asset, List<int>> {
  static const String ASSET_PATH = 'assets/objects/{hash1}/{hash2}';

  AssetDownloadTask(
      {required String source,
      required Asset dependency,
      required String workingDir,
      required Client client})
      : super(
            source: source,
            dependency: dependency,
            workingDir: workingDir,
            client: client);

  @override
  Future<bool> get tryLoadCache async {
    final FileSystem fs = GetIt.I.get<FileSystem>();

    try {
      File file = fs.file(
          '$workingDir${Platform.pathSeparator}${ASSET_PATH.replaceAll('{hash1}', dependency.hash.substring(0, 2)).replaceAll('{hash2}', dependency.hash)}');
      bool available =
          (await file.exists()) && // Verify the checksum and the size
              (dependency.hash.toLowerCase() ==
                  sha1
                      .convert(List.from(await file.readAsBytes()))
                      .toString()
                      .toLowerCase()) &&
              (await file.length() == dependency.size);
      if (available) {
        progress = 1;
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

  @override
  Future<void> download() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the asset ${dependency.hash}.');
    Request request = Request('GET', Uri.parse(dependency.url(source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await client.send(request);

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

        if (finished) {
          // Verify the checksum and the size
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              dependency.hash.toLowerCase()) {
            logger.severe('Asset ${dependency.hash}\'s checksum is invalid.');
            exceptionPhase = Phase.download;
            exception =
                Exception('Asset ${dependency.hash}\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != dependency.size) {
            logger.severe('Asset ${dependency.hash}\'s size is incorrect.');
            exceptionPhase = Phase.download;
            exception =
                Exception('Asset ${dependency.hash}\'s size is invalid.');
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
    final FileSystem fs = GetIt.I.get<FileSystem>();

    try {
      File local = fs.file(
          '$workingDir${Platform.pathSeparator}${ASSET_PATH.replaceAll('{hash1}', dependency.hash.substring(0, 2)).replaceAll('{hash2}', dependency.hash)}');
      await local.parent.create(recursive: true);
      await local.writeAsBytes(result!);
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
