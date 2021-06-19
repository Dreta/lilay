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

import 'package:get_it/get_it.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/version/arguments/argument.dart';
import 'package:lilay/core/download/version/assets/asset.dart';
import 'package:lilay/core/download/version/assets/asset_download_task.dart';
import 'package:lilay/core/download/version/assets/assets_index_download_task.dart';
import 'package:lilay/core/download/version/assets/core_download_task.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/version/library/library_download_task.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/download/version/version_download_task.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/versions_download_task.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/utils.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

/// [GameManager] manages starting the game, downloading the game,
/// receiving logs from the game etc.
class GameManager {
  final Profile profile;
  final CoreConfig config;
  final List<Function(Task, String)> errors = [];

  // Task: the current task
  // first int: the total progress (out of all tasks)
  // second int: the progress of the current task
  final List<Function(Task, double, double)> progressCallbacks = [];
  double totalProgress = 0;

  late VersionData data; // The downloaded version data for use later.

  void _error(Task task, String error) {
    Logger logger = GetIt.I.get<Logger>();
    logger.severe(error);
    for (Function(Task, String) callback in errors) {
      callback(task, error);
    }
  }

  void _progress(Task task, double totalProgress, double taskProgress) {
    for (Function(Task, double, double) callback in progressCallbacks) {
      callback(task, totalProgress, taskProgress);
    }
  }

  void startDownload() {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the version manifest.');
    VersionsDownloadTask task = VersionsDownloadTask(
        source: config.metaSource, workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(
            Task.downloadManifest,
            'An error occurred when downloading the version manifest:\n${task.exception.toString()} '
            '(Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        for (VersionInfo version in task.result!.versions) {
          if (version.id == profile.version) {
            downloadVersionData(version);
            return;
          }
        }
        _error(Task.downloadVersionData,
            'An error occurred when finding the version:\nCan\'t find version ${profile.version}.');
      }
    });
    task.start();
  }

  void downloadVersionData(VersionInfo info) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the version data for ${profile.name}.');
    VersionDownloadTask task = VersionDownloadTask(
        source: config.metaSource,
        dependency: info,
        workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(
            Task.downloadVersionData,
            'An error occurred when downloading the version data:\n${task.exception.toString()} '
            '(Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        data = task.result!;
        downloadAssetsIndex(task.result!);
      }
    });
    task.start();
  }

  void downloadAssetsIndex(VersionData data) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the assets index for ${profile.name}.');
    AssetsIndexDownloadTask task = AssetsIndexDownloadTask(
        source: config.metaSource,
        dependency: data,
        workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(
            Task.downloadAssetsIndex,
            'An error occurred when downloading the assets index:\n${task.exception.toString()} '
            '(Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        downloadAssets(data, task.result!);
      }
    });
    task.start();
  }

  void downloadAssets(VersionData data, Map<String, Asset> assets) {
    // TODO Simultaneously download multiple assets
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download assets for ${profile.name}.');
    Iterator<MapEntry<String, Asset>> iterator = assets.entries.iterator;
    if (iterator.moveNext()) {
      _downloadAsset(data, iterator);
    }
  }

  void _downloadAsset(
      VersionData data, Iterator<MapEntry<String, Asset>> iterator) {
    Logger logger = GetIt.I.get<Logger>();
    MapEntry<String, Asset> asset = iterator.current;
    logger.info('Downloading asset ${asset.key} for ${profile.name}.');
    AssetDownloadTask task = AssetDownloadTask(
        source: config.assetsSource,
        dependency: asset.value,
        workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(Task.downloadAssets,
            'An error occurred when downloading the asset ${asset.key} for ${profile.name}:\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        if (iterator.moveNext()) {
          _downloadAsset(data, iterator);
        } else {
          downloadLibraries(data);
        }
      }
    });
    task.start();
  }

  void downloadLibraries(VersionData data) {
    // TODO Simultaneously download multiple libraries
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download libraries for ${profile.name}.');
    Iterator<Library> iterator = data.libraries.iterator;
    if (iterator.moveNext()) {
      _downloadLibrary(data, iterator);
    }
  }

  void _downloadLibrary(VersionData data, Iterator<Library> iterator) {
    Logger logger = GetIt.I.get<Logger>();
    Library library = iterator.current;
    logger.info('Downloading library ${library.name}.');
    LibraryDownloadTask task = LibraryDownloadTask(
        source: config.librariesSource,
        dependency: library,
        workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(Task.downloadLibraries,
            'An error occurred when downloading the library ${library.name}:\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        if (iterator.moveNext()) {
          _downloadLibrary(data, iterator);
        } else {
          downloadCore(data);
        }
      }
    });
    task.start();
  }

  void downloadCore(VersionData data) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading client (${data.id}) of ${profile.name}.');
    CoreDownloadTask task = CoreDownloadTask(
        source: config.coreSource,
        dependency: data,
        workingDir: config.workingDirectory);
    double previousProgress = 0;
    task.callbacks.add(() {
      // We divide the progress into different parts.
      if (task.progress != previousProgress) {
        totalProgress +=
            (task.progress - previousProgress) * (1 / Task.values.length);
        previousProgress = task.progress;
        _progress(Task.downloadManifest, totalProgress, task.progress);
      }
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        _error(
            Task.downloadCore,
            'An error occurred when downloading the client (${data.id}) of ${profile.name}:'
            '\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})');
      }
    });
    task.callbacks.add(() {
      if (task.result != null) {
        task.save();
        _progress(Task.downloadCore, 1, 1);
      }
    });
    task.start();
  }

  GameManager({required this.profile, required this.config});

  void handleError(Function(Task, String) handler) {
    errors.add(handler);
  }

  void handleProgress(Function(Task, double, double) handler) {
    progressCallbacks.add(handler);
  }

  void startGame(VersionData data, Account account) async {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting game ${data.id} from profile ${profile.name}.');

    logger.info('Setting up the temporary native directory.');
    Directory natives = Directory(
        '${getTempDirectory()}${Platform.pathSeparator}lilayntvs-${getRandomString(8)}');
    await natives.create();
    for (Library library in data.libraries) {
      FriendlyDownload? native = library.platformNative;
      if (native != null) {
        File file = File(
            '${config.workingDirectory}${Platform.pathSeparator}libraries${Platform.pathSeparator}${native.path}');
        if (!await file.exists()) {
          _error(Task.start, 'Can\'t find required native at ${native.path}.');
          return;
        }
        file.copy(
            '${natives.path}${Platform.pathSeparator}${basename(file.path)}');
      }
    }

    logger.info('Setting up arguments.');
    List<String> gameArgs = profile.gameArguments.split(' ');
    List<String> jvmArgs = profile.jvmArguments.split(' ');
    if (data.arguments != null) {
      for (Argument argument in data.arguments!.gameParsed) {
        if (argument.applicable(account)) {
          gameArgs.add(argument.contextualValue(
              account, profile, config, data, natives.absolute.path));
        }
      }

      for (Argument argument in data.arguments!.jvmParsed) {
        if (argument.applicable(account)) {
          jvmArgs.add(argument.contextualValue(
              account, profile, config, data, natives.absolute.path));
        }
      }
    } else {
      for (String argument in (data.minecraftArguments ?? '').split(' ')) {
        if (argument.isEmpty) {
          continue;
        }
        Argument arg = Argument(value: argument, rules: []);
        gameArgs.add(arg.contextualValue(
            account, profile, config, data, natives.absolute.path));
      }
    }

    logger.info('Starting game ${data.id} with profile ${profile.name}.');

    List<String> args = [];
    args.addAll(jvmArgs);
    args.add(data.mainClass);
    args.addAll(gameArgs);

    await Process.start(
        profile.javaExecutable ?? GetIt.I.get<String>(instanceName: 'java'),
        args);
  }
}

enum Task {
  downloadManifest,
  downloadVersionData,
  downloadAssetsIndex,
  downloadAssets,
  downloadLibraries,
  downloadCore,
  start
}
