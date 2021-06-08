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

import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:logging/logging.dart';

import '../version_data.dart';
import 'asset.dart';

/// This task downloads the asset index file from a
/// [VersionData] and caches it accordingly.
///
/// This is a SHALLOW download. The associated assets with the index are NOT
/// downloaded within this task.
class AssetsIndexDownloadTask {
  static const String ASSETS_INDEX_PATH = 'assets/indexes/{type}.json';

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function(Map<String, Asset>) resultCallback;
  VersionData version;
  String workingDir;

  /// Prevent the callbacks from being called anymore.
  void disable() {
    progressCallback = (a) => {};
    errorCallback = (a) => {};
    resultCallback = (a) => {};
  }

  AssetsIndexDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.version,
      required this.workingDir});

  /// Check if the assets index already exist at the specified [workingDir],
  /// and that the hash matches.
  Future<bool> indexExists() async {
    File file = File(
        '$workingDir${Platform.pathSeparator}${ASSETS_INDEX_PATH.replaceAll('{type}', version.assets)}');
    return (await file.exists()) &&
        (version.assetIndex!.sha1.toLowerCase() ==
            sha1
                .convert(List.from(await file.readAsBytes()))
                .toString()
                .toLowerCase()) &&
        (await file.length() == version.assetIndex!.size);
  }

  /// Start to download the assets index from the download source [source].
  void start(String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the asset index ${version.assets}.');
    Request request = Request(
        'GET',
        Uri.parse(version.assetIndex!.url
            .replaceAll(CoreConfig.DEFAULT_META_SOURCE, source)));
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
          String json = utf8.decode(receivedBytes);
          Map<String, dynamic> assetsJson = jsonDecode(json)['objects'];
          Map<String, Asset> assets = {};
          logger.info('Parsing assets.');
          for (MapEntry<String, dynamic> asset in assetsJson.entries) {
            assets[asset.key] = Asset.fromJson(asset.value);
          }

          logger.info('Saved asset index ${version.assets}.');
          File local = File(
              '$workingDir${Platform.pathSeparator}${ASSETS_INDEX_PATH.replaceAll('{type}', version.assets)}');
          local.writeAsString(json);

          resultCallback(assets);
        }
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
