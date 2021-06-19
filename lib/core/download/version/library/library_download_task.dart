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
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/artifact.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:logging/logging.dart';

/// This task downloads an individual [Library].
///
/// NOTE: When checking for completion, the callback should
/// check if BOTH [result] and [resultNative] is available.
///
/// NOTE: For this download task, the following values of [result]
///       and [resultNative] indicates that:
///         `null`: The data is unavailable.
///         `[]`: This download is skipped.
///         `[...]`: The data is available.
class LibraryDownloadTask extends DownloadTask<Library, List<int>> {
  static const String LIBRARY_PATH = 'libraries/{path}';

  late List<int>? resultNative;

  LibraryDownloadTask(
      {required String source,
      required Library dependency,
      required String workingDir})
      : super(source: source, dependency: dependency, workingDir: workingDir);

  @override
  Future<bool> get tryLoadCache async {
    try {
      // Attempt to load the artifact first.
      // Handle two cases: the vanilla case with [dependency.downloads] or the
      // out-of-nowhere case with [dependency.url].
      bool artifactAvailable;
      File artifact;
      if (dependency.downloads != null) {
        artifact = File(
            '$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', dependency.downloads!.artifact!.path!)}');
        artifactAvailable = (await artifact.exists()) &&
            (dependency.downloads!.artifact!.sha1.toLowerCase() ==
                sha1
                    .convert(List.from(await artifact.readAsBytes()))
                    .toString()
                    .toLowerCase()) &&
            (await artifact.length() == dependency.downloads!.artifact!.size);
      } else {
        Artifact artif = Artifact(dependency.name);
        artifact = File(artif.path(workingDir));

        // Fetch SHA-1 hash of this artifact
        String hash =
            (await get(Uri.parse(artif.urlHash(dependency.url!)))).body.trim();

        artifactAvailable = (await artifact.exists()) &&
            (hash.toLowerCase() ==
                sha1
                    .convert(List.from(await artifact.readAsBytes()))
                    .toString()
                    .toLowerCase());
      }
      if (artifactAvailable) {
        result = await artifact.readAsBytes();
      }

      // Now attempt to load the natives.
      FriendlyDownload? native = dependency.platformNative;
      if (native == null) {
        return artifactAvailable;
      }

      File nativeFile = File(
          '$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', native.path!)}');
      bool nativeAvailable = (await nativeFile.exists()) &&
          (native.sha1.toLowerCase() ==
              sha1
                  .convert(List.from(await nativeFile.readAsBytes()))
                  .toString()
                  .toLowerCase()) &&
          (await nativeFile.length() == native.size);
      if (nativeAvailable) {
        resultNative = await nativeFile.readAsBytes();
      }
      return artifactAvailable && nativeAvailable;
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
    logger.info('Starting to download the library ${dependency.name}');

    if (!Rule.multiRulesApplicable(dependency.rules, null)) {
      logger.info(
          'The library ${dependency.name} is not applicable for download on this platform. Skipping.');
      result = [];
      resultNative = [];
      progress = 1;
      notify();
      return;
    }

    _downloadArtifact();
  }

  Future<void> _downloadArtifact() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the artifact of library ${dependency.name}.');

    Artifact artifact = Artifact(dependency.name);

    Request request = Request(
        'GET',
        Uri.parse(dependency.downloads == null
            ? artifact.url(dependency.url!)
            : dependency.downloads!.artifact!.url
                .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
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
      resp.stream.listen((chunk) async {
        received += chunk.length;
        logger.fine('Received ${chunk.length} bytes of data.');
        // The progress is divided into two parts - the artifact and the native.
        progress = received / resp.contentLength! / 2;
        notify();
        receivedBytes.addAll(chunk);

        if (received >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              (dependency.downloads == null
                  ? (await get(Uri.parse(artifact.urlHash(dependency.url!))))
                      .body
                      .trim()
                  : dependency.downloads!.artifact!.sha1.toLowerCase())) {
            logger.severe(
                'Library artifact ${dependency.name}\'s checksum is invalid.');
            exceptionPhase = Phase.download;
            exception = Exception(
                'Library artifact ${dependency.name}\'s checksum is invalid.');
            return;
          }

          if (dependency.downloads != null) {
            if (receivedBytes.length != dependency.downloads!.artifact!.size) {
              logger.severe(
                  'Library artifact ${dependency.name}\'s size is incorrect.');
              exceptionPhase = Phase.download;
              exception = Exception(
                  'Library artifact ${dependency.name}\'s size is incorrect.');
              return;
            }
          }

          result = receivedBytes;
          notify();

          _downloadNative();
        }
      });
    } catch (e) {
      exceptionPhase = Phase.download;
      exception = e;
      notify();
    }
  }

  Future<void> _downloadNative() async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the native of library ${dependency.name}.');

    FriendlyDownload? native = dependency.platformNative;
    if (native == null) {
      logger.info(
          'There are no natives that are applicable for this platform. Skipping.');
      resultNative = [];
      progress = 1;
      notify();
      return;
    }

    Request request = Request(
        'GET',
        Uri.parse(native.url
            .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
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
        // The progress is divided into two parts - the artifact and the native.
        progress = 0.5 + received / resp.contentLength!;
        notify();
        receivedBytes.addAll(chunk);

        if (finished) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              native.sha1.toLowerCase()) {
            logger.severe(
                'Library native ${dependency.name}\'s checksum is invalid.');
            exceptionPhase = Phase.download;
            exception = Exception(
                'Library native ${dependency.name}\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != native.size) {
            logger.severe(
                'Library native ${dependency.name}\'s size is incorrect.');
            exceptionPhase = Phase.download;
            exception = Exception(
                'Library native ${dependency.name}\'s size is incorrect.');
            return;
          }

          resultNative = receivedBytes;
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
      if (result!.isNotEmpty) {
        File local = File(
            '$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', dependency.downloads == null ? Artifact(dependency.name).path(workingDir) : dependency.downloads!.artifact!.path!)}');
        local.parent.create(recursive: true);
        local.writeAsBytes(result!);
      }

      if (resultNative!.isNotEmpty) {
        File local = File(
            '$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', dependency.platformNative!.path!)}');
        local.parent.create(recursive: true);
        local.writeAsBytes(resultNative!);
      }
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}