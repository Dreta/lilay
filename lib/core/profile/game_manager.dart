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

import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/configuration/core/core_config.dart';
import 'package:lilay/core/download/assets/asset.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/arguments/argument.dart';
import 'package:lilay/core/download/version/assets/asset_download_task.dart';
import 'package:lilay/core/download/version/assets/assets_index_download_task.dart';
import 'package:lilay/core/download/version/assets/core_download_task.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/version/library/library_download_task.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/download/version/version_download_task.dart';
import 'package:lilay/core/download/version/version_parent_download_task.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:lilay/core/download/versions/versions_download_task.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/ui/launch/launch_provider.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:system_info/system_info.dart';

import '../../utils.dart';

/// [GameManager] manages starting the game, downloading the game,
/// receiving logs from the game etc.
class GameManager {
  final Profile profile;
  final CoreConfig config;
  final LaunchProvider parent;

  String? error;
  Task? task;
  double totalProgress = 0;
  String? subtitle;

  VersionData? data; // The downloaded version data for use later.

  void startDownload() {
    final FileSystem fs = GetIt.I.get<FileSystem>();

    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the version manifest.');
    final Client client = Client();
    VersionsDownloadTask task = VersionsDownloadTask(
        source: config.metaSource,
        workingDir: config.workingDirectory,
        client: client);
    this.task = Task.downloadManifest;
    subtitle = 'Versions Manifest';
    parent.notify();
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress = task.progress * (1 / 16);
      subtitle = 'Versions Manifest (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        client.close();
        error =
            'An error occurred when downloading the version manifest:\n${task.exception.toString()} '
            '(Phase: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        client.close();
        await task.save();
        // Find from manifest
        for (VersionInfo version in task.result!.versions) {
          if (version.id == profile.version) {
            downloadVersionData(task.result!, version);
            task.cancelled = true;
            return;
          }
        }
        // Use local version
        Directory versions = fs.directory(
            '${config.workingDirectory}${Platform.pathSeparator}versions');
        await for (FileSystemEntity directory in versions.list()) {
          if (directory is Directory) {
            File data = fs.file(join(
                directory.absolute.path, '${basename(directory.path)}.json'));
            if (await data.exists()) {
              try {
                Map<String, dynamic> json =
                    jsonDecode(await data.readAsString());
                if (json.containsKey('type') &&
                    json['type'].toString().contains('old')) {
                  continue;
                }
                VersionData vData = VersionData.fromJson(
                    json); // Parse and create the VersionInfo
                if (vData.id == profile.version) {
                  totalProgress = 2 / 16; // Skip downloading the version data
                  this.data = vData;
                  downloadVersionParent(task.result!, vData);
                  task.cancelled = true;
                  return;
                }
              } catch (e) {
                // Ignore parsing errors for the version data - we will discard this version
                logger.severe(
                    'Failed to parse the version data in ${directory.absolute.path}: $e.');
              }
            }
          }
        }

        error =
            'An error occurred when finding the version:\nCan\'t find version ${profile.version}.';
        parent.notify();
      }
    });
    task.start();
  }

  void downloadVersionData(VersionManifest manifest, VersionInfo info) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the version data for ${profile.name}.');
    final Client client = Client();
    VersionDownloadTask task = VersionDownloadTask(
        source: config.metaSource,
        dependency: info,
        workingDir: config.workingDirectory,
        client: client);
    this.task = Task.downloadVersionData;
    subtitle = 'Version Data ${info.id}';
    parent.notify();
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress += (1 / 16) + task.progress * (1 / 16);
      subtitle = 'Version Data ${info.id} (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        client.close();
        error =
            'An error occurred when downloading the version data:\n${task.exception.toString()} '
            '(Phailese: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        client.close();
        await task.save();
        data = task.result!;
        downloadVersionParent(manifest, task.result!);
        task.cancelled = true;
      }
    });
    task.start();
  }

  void downloadVersionParent(VersionManifest manifest, VersionData data) {
    Logger logger = GetIt.I.get<Logger>();
    if (data.inheritsFrom != null) {
      logger.info('Downloading the parent of version ${data.id}.');
      Client client = Client();
      VersionParentDownloadTask task = VersionParentDownloadTask(
          source: config.metaSource,
          manifest: manifest,
          dependency: data,
          workingDir: config.workingDirectory,
          client: client);
      this.task = Task.downloadVersionParent;
      subtitle = 'Parent ${data.inheritsFrom} of ${data.id}';
      parent.notify();
      task.callbacks.add(() {
        // We divide the progress into different parts
        totalProgress += (2 / 16) + task.progress * (1 / 16);
        subtitle =
            'Parent ${data.inheritsFrom} of ${data.id} (${(task.progress * 100).round()}%)';
        parent.notify();
      });
      task.callbacks.add(() {
        if (task.exception != null) {
          client.close();
          error =
              'An error occurred when downloading the parent version:\n${task.exception.toString()} '
              '(Phase: ${task.exceptionPhase.toString()})';
          parent.notify();
        }
      });
      task.callbacks.add(() async {
        if (task.result != null) {
          client.close();
          await task.save();
          downloadAssetsIndex(data);
          task.cancelled = true;
        }
      });
      task.start();
    } else {
      downloadAssetsIndex(data);
    }
  }

  void downloadAssetsIndex(VersionData data) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading the assets index for ${profile.name}.');
    final Client client = Client();
    AssetsIndexDownloadTask task = AssetsIndexDownloadTask(
        source: config.metaSource,
        dependency: data,
        workingDir: config.workingDirectory,
        client: client);
    this.task = Task.downloadAssetsIndex;
    subtitle = 'Assets index ${data.assets}';
    parent.notify();
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress = (3 / 16) + task.progress * (2 / 16);
      subtitle =
          'Assets index ${data.assets} (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        client.close();
        error =
            'An error occurred when downloading the assets index:\n${task.exception.toString()} '
            '(Phase: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        client.close();
        await task.save();
        downloadAssets(data, task.result!);
        task.cancelled = true;
      }
    });
    task.start();
  }

  void downloadAssets(VersionData data, Map<String, Asset> assets) {
    // TODO Simultaneously download multiple assets
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download assets for ${profile.name}.');
    this.task = Task.downloadAssets;
    parent.notify();
    Iterator<MapEntry<String, Asset>> iterator = assets.entries.iterator;
    final Client client = Client();
    if (iterator.moveNext()) {
      _downloadAsset(data, iterator, 1, assets.length, client);
    }
  }

  void _downloadAsset(
      VersionData data,
      Iterator<MapEntry<String, Asset>> iterator,
      int current,
      int total,
      Client client) async {
    Logger logger = GetIt.I.get<Logger>();
    MapEntry<String, Asset> asset = iterator.current;
    logger.fine('Downloading asset ${asset.key} for ${profile.name}.');
    subtitle = asset.key;
    parent.notify();
    AssetDownloadTask task = AssetDownloadTask(
        source: config.assetsSource,
        dependency: asset.value,
        workingDir: config.workingDirectory,
        client: client);
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress = (5 / 16) +
          (((current - 1) / total) + (task.progress / total)) * (4 / 16);
      subtitle = '${asset.key} (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        error =
            'An error occurred when downloading the asset ${asset.key} for ${profile.name}:\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        await task.save();
        if (iterator.moveNext()) {
          _downloadAsset(data, iterator, current + 1, total, client);
        } else {
          client.close();
          downloadLibraries(data);
        }
        task.cancelled = true;
      }
    });
    task.start();
  }

  void downloadLibraries(VersionData data) {
    // TODO Simultaneously download multiple libraries
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Starting to download libraries for ${profile.name}.');
    this.task = Task.downloadLibraries;
    parent.notify();

    Iterator<Library> iterator = data.libraries.iterator;
    final Client client = Client();
    if (iterator.moveNext()) {
      _downloadLibrary(data, iterator, 1, data.libraries.length, client);
    }
  }

  void _downloadLibrary(VersionData data, Iterator<Library> iterator,
      int current, int total, Client client) {
    Logger logger = GetIt.I.get<Logger>();
    Library library = iterator.current;
    logger.fine('Downloading library ${library.name}.');
    LibraryDownloadTask task = LibraryDownloadTask(
        source: config.librariesSource,
        dependency: library,
        workingDir: config.workingDirectory,
        client: client);
    subtitle = library.name;
    parent.notify();
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress = (9 / 16) +
          (((current - 1) / total) + (task.progress / total)) * (4 / 16);
      subtitle = '${library.name} (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        error =
            'An error occurred when downloading the library ${library.name}:\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null && task.resultNative != null) {
        await task.save();
        if (iterator.moveNext()) {
          _downloadLibrary(data, iterator, current + 1, total, client);
        } else {
          client.close();
          downloadCore(data);
        }
        task.cancelled = true;
      }
    });
    task.start();
  }

  void downloadCore(VersionData data) {
    Logger logger = GetIt.I.get<Logger>();
    logger.info('Downloading client (${data.id}) of ${profile.name}.');
    final Client client = Client();
    CoreDownloadTask task = CoreDownloadTask(
        source: config.coreSource,
        dependency: data,
        workingDir: config.workingDirectory,
        client: Client());
    this.task = Task.downloadCore;
    subtitle = '${data.id} client';
    parent.notify();
    task.callbacks.add(() {
      // We divide the progress into different parts.
      totalProgress = (13 / 16) + task.progress * (3 / 16);
      subtitle = '${data.id} client (${(task.progress * 100).round()}%)';
      parent.notify();
    });
    task.callbacks.add(() {
      if (task.exception != null) {
        client.close();
        error =
            'An error occurred when downloading the client (${data.id}) of ${profile.name}:'
            '\n${task.exception.toString()} (Phase: ${task.exceptionPhase.toString()})';
        parent.notify();
      }
    });
    task.callbacks.add(() async {
      if (task.result != null) {
        client.close();
        await task.save();
        parent.notify();
      }
    });
    task.start();
  }

  GameManager(
      {required this.profile, required this.config, required this.parent});

  void startGame(VersionData data, Account account) async {
    final FileSystem fs = GetIt.I.get<FileSystem>();

    Logger logger = GetIt.I.get<Logger>();
    this.task = Task.start;
    parent.status = LaunchStatus.started;
    subtitle = null;
    logger.info('Starting game ${data.id} from profile ${profile.name}.');

    logger.info('Setting up the temporary native directory.');
    Directory natives = fs.directory(
        '${getTempDirectory()}${Platform.pathSeparator}lilayntvs-${getRandomString(8)}');
    logger.info('Natives directory available at ${natives.path}.');
    await natives.create();
    for (Library library in data.libraries) {
      if (Rule.multiRulesApplicable(library.rules, account, profile)) {
        FriendlyDownload? native = library.platformNative;
        if (native != null) {
          File file = fs.file(
              '${config.workingDirectory}${Platform.pathSeparator}libraries${Platform.pathSeparator}${native.path}');
          if (!await file.exists()) {
            error = 'Can\'t find required native at ${native.path}.';
            parent.notify();
            return;
          }
          await file.copy(
              '${natives.path}${Platform.pathSeparator}${basename(file.path)}');

          File target = fs.file(
              '${natives.path}${Platform.pathSeparator}${basename(file.path)}');
          try {
            Archive archive =
                ZipDecoder().decodeBytes(await target.readAsBytes());
            for (ArchiveFile file in archive.files) {
              if (file.name.toLowerCase().contains('meta') ||
                  file.name.toLowerCase().contains('manifest')) {
                continue; // Hardcode files that shouldn't be extracted
              }
              if (file.isFile) {
                File unzip = fs.file(
                    '${natives.path}${Platform.pathSeparator}${file.name}');
                await unzip.parent.create(recursive: true);
                await unzip.writeAsBytes(file.content);
              }
            }
            await target.delete();
          } catch (ignored) {}
        }
      }
    }

    logger.info('Setting up arguments.');
    List<String> gameArgs = profile.gameArguments.split(' ');
    List<String> jvmArgs = profile.jvmArguments.split(' ');
    if (data.arguments != null) {
      for (Argument argument in data.arguments!.gameParsed) {
        if (argument.applicable(account, profile)) {
          gameArgs.addAll(argument.contextualValue(
              account, profile, config, data, natives.path));
        }
      }

      for (Argument argument in data.arguments!.jvmParsed) {
        if (argument.applicable(account, profile)) {
          jvmArgs.addAll(argument.contextualValue(
              account, profile, config, data, natives.path));
        }
      }
    } else {
      for (String argument in (data.minecraftArguments ?? '').split(' ')) {
        if (argument.isEmpty) {
          continue;
        }
        Argument arg = Argument(value: [argument], rules: []);
        gameArgs.addAll(
            arg.contextualValue(account, profile, config, data, natives.path));
      }
    }

    if (data.arguments == null) {
      // Fill in our own JVM arguments
      if (Platform.isMacOS) {
        jvmArgs.add('-XstartOnFirstThread');
      }
      if (Platform.isWindows) {
        jvmArgs.add(
            '-XX:HeadDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.headdump');
      }
      if (Platform.isWindows &&
          RegExp('^10\\.').hasMatch(Platform.operatingSystemVersion)) {
        jvmArgs.add('-Dos.name=Windows 10');
        jvmArgs.add('-Dos.version=10.0');
      }
      if (SysInfo.kernelArchitecture == 'x86') {
        jvmArgs.add('-Xss1M');
      }
      jvmArgs.addAll(Argument(value: [
        '-Djava.library.path=\${natives_directory}',
        '-Dminecraft.launcher.brand=\${launcher_name}',
        '-Dminecraft.launcher.version=\${launcher_version}',
        '-cp',
        '\${classpath}'
      ], rules: [])
          .contextualValue(account, profile, config, data, natives.path));
    }

    List<String> args = [];
    args.addAll(jvmArgs);
    args.add(data.mainClass);
    args.addAll(gameArgs);

    logger.info('Starting game ${data.id} with profile ${profile.name}.');
    logger.info('Arguments: ${args.join(' ')}');

    Process process = await Process.start(
        profile.javaExecutable ?? GetIt.I.get<String>(instanceName: 'java'),
        args,
        workingDirectory: profile.gameDirectory ?? config.workingDirectory);
    parent.instances++;
    parent.notify();
    int exitCode = await process.exitCode;
    parent.instances--;
    if (parent.instances == 0) {
      parent.status = null; // Remove "running" status when the process ends
    }
    if (exitCode != 0) {
      parent.crashed = true;
    }
    parent.notify();
  }
}

enum Task {
  downloadManifest,
  downloadVersionData,
  downloadVersionParent,
  downloadAssetsIndex,
  downloadAssets,
  downloadLibraries,
  downloadCore,
  start
}

extension TaskExtension on Task {
  String get text {
    return {
      Task.downloadManifest: 'Downloading manifest',
      Task.downloadVersionData: 'Verifying and downloading version data',
      Task.downloadVersionParent: 'Verifying and downloading version parent',
      Task.downloadAssetsIndex: 'Verifying and downloading assets index',
      Task.downloadAssets: 'Verifying and downloading assets',
      Task.downloadLibraries: 'Verifying and downloading libraries',
      Task.downloadCore: 'Verifying and downloading client',
      Task.start: 'Starting game'
    }[this]!;
  }
}
