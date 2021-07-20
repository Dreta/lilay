/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
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

import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/version/version_download_task.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:lilay/utils.dart';

import 'version_data.dart';

/// Download the metadata JSON file from [VersionData.inheritsFrom]
/// of a [VersionData].
///
/// This is a SHALLOW download. The associated assets, libraries AND PARENT etc.
/// are NOT downloaded within this task.
class VersionParentDownloadTask extends DownloadTask<VersionData, VersionData> {
  VersionManifest manifest;

  /// The local version manifest that we are inheriting from.
  /// Will be null if [childTask] is not null.
  VersionData? local;

  /// The download task for the parent version. Will be null if [local] is not null.
  VersionDownloadTask? childTask;

  VersionParentDownloadTask(
      {required String source,
      required this.manifest,
      required VersionData dependency,
      required String workingDir,
      required Client client})
      : super(
            source: source,
            dependency: dependency,
            workingDir: workingDir,
            client: client) {
    assert(dependency.inheritsFrom != null);
  }

  @override
  Future<void> init() async {
    // Find the VersionInfo from the version manifest provided.
    VersionInfo? info;
    for (VersionInfo i in manifest.versions) {
      if (i.id == dependency.inheritsFrom) {
        info = i;
      }
    }
    if (info == null) {
      // Can't find from version manifest. Find the path ourselves locally.
      await for (VersionData version in getAvailableVersions(workingDir)) {
        if (version.id == dependency.inheritsFrom) {
          local = version;
          return;
        }
      }
      throw Exception(
          "Can\'t find the parent version ${dependency.inheritsFrom} for ${dependency.id}.");
    } else {
      // Found in version manifest. Construct a version download task for it.
      childTask = VersionDownloadTask(
          source: source,
          dependency: info,
          workingDir: workingDir,
          client: client);

      // Order MATTERS! We must copy our properties before the callbacks can access them!
      childTask!.callbacks.add(() {
        // Our callback for copying properties from the child task to us.
        this.progress = childTask!.progress;
        this.exception = childTask!.exception;
        this.exceptionPhase = childTask!.exceptionPhase;
        this.result = childTask!.result;
        // If the child task finished, then apply the parent to our dependency.
        if (result != null) {
          dependency.parent = result;
        }
      });
      // Add our callbacks to the child so they get called.
      for (TaskUpdateCallback callback in callbacks) {
        childTask!.callbacks.add(() {
          // Only call our callback if WE AND THE CHILD both aren't cancelled.
          if (!cancelled) {
            callback();
          }
        });
      }
    }
  }

  @override
  Future<bool> get tryLoadCache async {
    if (local != null) {
      // If a local version is available, use the local version.
      result = local;
      dependency.parent = local;
      progress = 1;
      return true;
    } else if (childTask != null) {
      // Check if the cache is available in our child task.
      if (await childTask!.tryLoadCache) {
        // If it is available, then apply the parent to our dependency.
        result = childTask!.result;
        dependency.parent = childTask!.result;
        progress = 1;
        return true;
      }
    }
    return false; // Will never reach this
  }

  @override
  Future<void> download() async {
    // Download from our child task if available.
    if (childTask != null) {
      return childTask!.download();
    }
  }

  @override
  Future<void> save() async {
    final FileSystem fs = GetIt.I.get<FileSystem>();

    try {
      // Save the parent file.
      File local = fs.file(
          '$workingDir${Platform.pathSeparator}${VersionDownloadTask.VERSION_PATH.replaceAll('{version}', dependency.inheritsFrom!)}');
      await local.parent.create(recursive: true);
      await local.writeAsString(jsonEncode(result!.toJson()));
    } catch (e) {
      exceptionPhase = Phase.save;
      exception = e;
      notify();
    }
  }
}
