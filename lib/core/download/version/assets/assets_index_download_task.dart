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

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:logging/logging.dart';

import '../../task.dart';
import '../version_data.dart';
import 'asset.dart';

/// This task downloads the asset index file from a
/// [VersionData] and caches it accordingly.
///
/// This is a SHALLOW download. The associated assets with the index are NOT
/// downloaded within this task.
class AssetsIndexDownloadTask
    extends DownloadTask<VersionData, Map<String, Asset>> {
  static const String ASSETS_INDEX_PATH = 'assets/indexes/{type}.json';

  AssetsIndexDownloadTask(
      {required String source,
      required VersionData dependency,
      required String workingDir})
      : super(source: source, dependency: dependency, workingDir: workingDir);

  /// Check if the assets index already exist at the specified [workingDir],
  /// and that the hash matches.
  @override
  Future<bool> get tryLoadCache async {
    try {
      File file = File(
          '$workingDir${Platform.pathSeparator}${ASSETS_INDEX_PATH.replaceAll('{type}', dependency.assets)}');
      bool available = (await file.exists()) &&
          (dependency.assetIndex!.sha1.toLowerCase() ==
              sha1
                  .convert(List.from(await file.readAsBytes()))
                  .toString()
                  .toLowerCase()) &&
          (await file.length() == dependency.assetIndex!.size);
      if (available) {
        Map<String, dynamic> assetsJson =
            jsonDecode(await file.readAsString())['objects'];
        result = {};
        for (MapEntry<String, dynamic> asset in assetsJson.entries) {
          result![asset.key] = Asset.fromJson(asset.value);
        }
        progress = 1;
      }
      return available;
    } catch (e) {
      exceptionPhase = Phase.loadCache;
      exception = e;
      notify();
      return false;
    }
  }

  /// Start to download the assets index from the download source [source].
  @override
  Future<void> download() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download the asset index ${dependency.assets}.');
    Request request = Request(
        'GET',
        Uri.parse(dependency.assetIndex!.url
            .replaceAll(CoreConfig.DEFAULT_META_SOURCE, source)));
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
          String json = utf8.decode(receivedBytes);
          Map<String, dynamic> assetsJson = jsonDecode(json)['objects'];
          Map<String, Asset> assets = {};
          logger.info('Parsing assets.');
          for (MapEntry<String, dynamic> asset in assetsJson.entries) {
            assets[asset.key] = Asset.fromJson(asset.value);
          }

          result = assets;
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
      File local = File(
          '$workingDir${Platform.pathSeparator}${ASSETS_INDEX_PATH.replaceAll('{type}', dependency.assets)}');
      await local.parent.create(recursive: true);
      local.writeAsString(jsonEncode({
        'objects': result!.map((key, value) => MapEntry(key, value.toJson()))
      }));
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
