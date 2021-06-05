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

import 'package:http/http.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/versions/version_info.dart';

import 'version_data.dart';

/// Download the metadata JSON file of the [version]. The downloaded file
/// will be saved automatically.
///
/// This is a SHALLOW download. The associated assets, client, libraries etc.
/// are NOT downloaded within this task.
class VersionDownloadTask {
  static const String VERSION_PATH = 'versions/{version}/{version}.json';

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function(VersionData) resultCallback;
  VersionInfo version;
  String workingDir;

  VersionDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.version,
      required this.workingDir});

  /// Prevent the callbacks from being called anymore.
  void disable() {
    progressCallback = (a) => {};
    errorCallback = (a) => {};
    resultCallback = (a) => {};
  }

  /// Check if the version metadata already exist at the specified [workingDir].
  Future<bool> metadataExists() async {
    return File(
            '$workingDir${Platform.pathSeparator}${VERSION_PATH.replaceAll('{version}', version.id)}')
        .exists();
  }

  /// Start to download the version metadata from the download source [source].
  void start(String source) async {
    Request request = Request(
        'GET',
        Uri.parse(
            version.url.replaceAll(CoreConfig.DEFAULT_META_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();

      resp.stream.handleError((error) => errorCallback(error.toString()));

      int received = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        received += chunk.length;
        if (resp.contentLength != null) {
          progressCallback(received / resp.contentLength!);
        }
        receivedBytes.addAll(chunk);

        if (received >= resp.contentLength!) {
          String json = utf8.decode(receivedBytes);
          VersionData data = VersionData.fromJson(jsonDecode(json));

          File local = File(
              '$workingDir${Platform.pathSeparator}${VERSION_PATH.replaceAll('{version}', version.id)}');
          local.writeAsString(json);

          resultCallback(data);
        }
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
