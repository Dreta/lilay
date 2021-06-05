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
import 'package:http/http.dart';
import 'package:lilay/core/download/version/assets/asset.dart';

/// Download all [assets]. The downloaded files
/// will be saved automatically.
class AssetsDownloadTask {
  static const String ASSET_PATH = 'assets/objects/{hash1}/{hash2}';

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function resultCallback;
  int totalSize;
  Iterable<Asset> assets;
  String workingDir;

  int received = 0;

  AssetsDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.totalSize,
      required this.assets,
      required this.workingDir});

  /// Start to download the assets from the [source].
  void start(String source) async {
    Iterator<Asset> it = assets.iterator;
    it.moveNext();
    _download(it, source);
  }

  void _download(Iterator<Asset> it, String source) async {
    Request request = Request('GET', Uri.parse(it.current.url(source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();

      // possible issue: multiple errors
      resp.stream.handleError((error) => errorCallback(error.toString()));

      int localReceived = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        localReceived += chunk.length;
        received += chunk.length;
        progressCallback(received / totalSize);
        receivedBytes.addAll(chunk);

        if (localReceived >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              it.current.hash.toLowerCase()) {
            errorCallback('File ${it.current.hash}\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != it.current.size) {
            errorCallback('File ${it.current.hash}\'s size is incorrect.');
            return;
          }

          File('$workingDir${Platform.pathSeparator}${ASSET_PATH.replaceAll('{hash1}', it.current.hash.substring(0, 2)).replaceAll('{hash2}', it.current.hash)}')
              .writeAsBytes(receivedBytes);
        }
        it.moveNext();
        _download(it, source);
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
