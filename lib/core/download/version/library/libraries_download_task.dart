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
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/library.dart';

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

  LibrariesDownloadTask(
      {required this.progressCallback,
      required this.errorCallback,
      required this.resultCallback,
      required this.libraries,
      required this.account,
      required this.workingDir});

  /// Start to download the libraries from the [source].
  void start(String source) async {
    Iterator<Library> it = libraries.iterator;
    it.moveNext();
    _downloadArtifact(it, source);
  }

  void _downloadArtifact(Iterator<Library> it, String source) async {
    // Check the rules
    Library lib = it.current;
    if (!Rule.multiRulesApplicable(lib.rules, account)) {
      _downloadNext(it, source);
      return;
    }

    // Download the artifact
    Request request = Request(
        'GET',
        Uri.parse(lib.downloads.artifact.url
            .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';
    StreamedResponse resp = await request.send();
    resp.stream.handleError((error) => errorCallback(error.toString()));

    int localReceived = 0;
    List<int> receivedBytes = [];

    resp.stream.listen((chunk) {
      localReceived += chunk.length;
      receivedBytes.addAll(chunk);

      if (localReceived >= resp.contentLength!) {
        if (sha1.convert(receivedBytes).toString().toLowerCase() !=
            lib.downloads.artifact.sha1.toLowerCase()) {
          errorCallback(
              'The artifact of library ${lib.name}\'s checksum is invalid.');
          return;
        }

        if (receivedBytes.length != lib.downloads.artifact.size) {
          errorCallback(
              'The artifact of library ${lib.name}\'s size is incorrect.');
          return;
        }

        File('$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', lib.downloads.artifact.path!)}')
            .writeAsBytes(receivedBytes);
      }
      _downloadNatives(it, source);
    });
  }

  void _downloadNatives(Iterator<Library> it, String source) async {
    Library lib = it.current;
    if (lib.natives == null) {
      _downloadNext(it, source); // Skip
      return;
    }

    FriendlyDownload native;
    if (Platform.isWindows && lib.natives!.windows != null) {
      native = lib.downloads.classifiers!.nativesWindows!;
    } else if (Platform.isMacOS && lib.natives!.osx != null) {
      native = lib.downloads.classifiers!.nativesMacOS!;
    } else if (Platform.isLinux && lib.natives!.linux != null) {
      native = lib.downloads.classifiers!.nativesLinux!;
    } else {
      _downloadNext(it, source); // Skip
      return;
    }

    Request request = Request(
        'GET',
        Uri.parse(native.url
            .replaceAll(CoreConfig.DEFAULT_LIBRARIES_SOURCE, source)));
    request.headers['User-Agent'] = 'lilay-minecraft-launcher';
    StreamedResponse resp = await request.send();
    resp.stream.handleError((error) => errorCallback(error.toString()));

    int localReceived = 0;
    List<int> receivedBytes = [];

    resp.stream.listen((chunk) {
      localReceived += chunk.length;
      receivedBytes.addAll(chunk);

      if (localReceived >= resp.contentLength!) {
        if (sha1.convert(receivedBytes).toString().toLowerCase() !=
            native.sha1.toLowerCase()) {
          errorCallback(
              'The native of library ${lib.name}\'s checksum is invalid.');
          return;
        }

        if (receivedBytes.length != native.size) {
          errorCallback(
              'The native of library ${lib.name}\'s size is incorrect.');
          return;
        }

        File('$workingDir${Platform.pathSeparator}${LIBRARY_PATH.replaceAll('{path}', native.path!)}')
            .writeAsBytes(receivedBytes);
      }
      _downloadNext(it, source);
    });
  }

  void _downloadNext(Iterator<Library> it, String source) {
    receivedLibs += 1;
    progressCallback(receivedLibs / libraries.length);
    it.moveNext();
    _downloadArtifact(it, source);
  }
}
