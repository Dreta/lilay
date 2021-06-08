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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:logging/logging.dart';
import 'package:system_info/system_info.dart';

/// Download all [libraries].
/// The downloaded files will be saved automatically.
class LibrariesDownloadTask {
  static const String LIBRARY_PATH = 'libraries/{path}';

  Function(double) progressCallback;
  Function(String) errorCallback;
  Function resultCallback;
  Iterable<Library> libraries;
  Account account;
  String workingDir;

  int receivedLibs = 0;

  /// Prevent the callbacks from being called anymore.
  void disable() {
    progressCallback = (a) => {};
    errorCallback = (a) => {};
    resultCallback = () => {};
  }

  LibrariesDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.libraries,
      required this.account,
      required this.workingDir});

  /// Start to download the libraries from the [source].
  void start(String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download libraries.');
    Iterator<Library> it = libraries.iterator;
    it.moveNext();
    _downloadArtifact(it, source);
  }

  String _mapNativePlaceholders(String s) {
    return s..replaceAll('{arch}', SysInfo.kernelBitness.toString());
  }

  void _downloadArtifact(Iterator<Library> it, String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the artifact of library ${it.current.name}.');
    // Check the rules
    Library lib = it.current;
    if (!Rule.multiRulesApplicable(lib.rules, account)) {
      logger.info(
          'The library ${it.current.name} is not applicable for download. Skipping.');
      _downloadNext(it, source);
      return;
    }
    if (lib.natives == null) {
      logger.info(
          'There are no artifacts for this library. Skipping to natives.');
      _downloadNatives(it, source); // Skip
      return;
    }

    // Download the artifact
    Request request = Request(
        'GET',
        Uri.parse(lib.downloads.artifact!.url
            .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();
      resp.stream.handleError((error) => errorCallback(error.toString()));

      int localReceived = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        logger.fine('Received ${chunk.length} bytes of data.');
        localReceived += chunk.length;
        receivedBytes.addAll(chunk);

        if (localReceived >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              lib.downloads.artifact!.sha1.toLowerCase()) {
            logger.severe(
                'The artifact of library ${lib.name}\'s checksum is invalid.');
            errorCallback(
                'The artifact of library ${lib.name}\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != lib.downloads.artifact!.size) {
            logger.severe(
                'The artifact of library ${lib.name}\'s size is incorrect.');
            errorCallback(
                'The artifact of library ${lib.name}\'s size is incorrect.');
            return;
          }

          logger.info('Saving the artifact of library ${lib.name}.');
          File('$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', lib.downloads.artifact!.path!)}')
              .writeAsBytes(receivedBytes);
        }
        _downloadNatives(it, source);
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  void _downloadNatives(Iterator<Library> it, String source) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the natives of library ${it.current.name}.');
    Library lib = it.current;
    if (lib.natives == null) {
      logger.info('There are no natives for this library. Skipping.');
      _downloadNext(it, source); // Skip
      return;
    }

    FriendlyDownload native;
    if (Platform.isWindows && lib.natives!.windows != null) {
      String index = _mapNativePlaceholders(lib.natives!.windows!);
      native = FriendlyDownload.fromJson(
          lib.downloads.classifiers[index] as Map<String, dynamic>);
      logger.info('Downloading native $index.');
    } else if (Platform.isMacOS && lib.natives!.osx != null) {
      String index = _mapNativePlaceholders(lib.natives!.osx!);
      native = FriendlyDownload.fromJson(
          lib.downloads.classifiers[index] as Map<String, dynamic>);
      logger.info('Downloading native $index.');
    } else if (Platform.isLinux && lib.natives!.linux != null) {
      String index = _mapNativePlaceholders(lib.natives!.linux!);
      native = FriendlyDownload.fromJson(
          lib.downloads.classifiers[index] as Map<String, dynamic>);
      logger.info('Downloading native $index.');
    } else {
      logger.info(
          'There are no natives that are applicable for this operating system. Skipping.');
      _downloadNext(it, source); // Skip
      return;
    }

    Request request = Request(
        'GET',
        Uri.parse(native.url
            .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';

    try {
      StreamedResponse resp = await request.send();
      resp.stream.handleError((error) => errorCallback(error.toString()));

      int localReceived = 0;
      List<int> receivedBytes = [];

      resp.stream.listen((chunk) {
        logger.fine('Received ${chunk.length} bytes of data.');
        localReceived += chunk.length;
        receivedBytes.addAll(chunk);

        if (localReceived >= resp.contentLength!) {
          if (sha1.convert(receivedBytes).toString().toLowerCase() !=
              native.sha1.toLowerCase()) {
            logger.severe(
                'The native of library ${lib.name}\'s checksum is invalid.');
            errorCallback(
                'The native of library ${lib.name}\'s checksum is invalid.');
            return;
          }

          if (receivedBytes.length != native.size) {
            logger.severe(
                'The native of library ${lib.name}\'s size is incorrect.');
            errorCallback(
                'The native of library ${lib.name}\'s size is incorrect.');
            return;
          }

          logger.info('Saving the native of library ${lib.name}.');
          File('$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', native.path!)}')
              .writeAsBytes(receivedBytes);
        }
        _downloadNext(it, source);
      });
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  void _downloadNext(Iterator<Library> it, String source) {
    receivedLibs += 1;
    progressCallback(receivedLibs / libraries.length);
    it.moveNext();
    _downloadArtifact(it, source);
  }
}
