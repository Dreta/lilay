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

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/version/arguments/arguments_data.dart';
import 'package:lilay/core/download/version/assets/assets_index.dart';
import 'package:lilay/core/download/version/assets/core_downloads.dart';
import 'package:lilay/core/download/version/version_data.dart';
import 'package:lilay/core/download/version/version_download_task.dart';
import 'package:lilay/core/download/version/version_parent_download_task.dart';
import 'package:lilay/core/download/versions/latest_version.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'version_parent_download_task_test.mocks.dart';

@GenerateMocks([Client, VersionDownloadTask])
void main() {
  group('VersionParentDownloadTask', () {
    group('init', () {
      test('Should correctly locate local parent version manifest.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifest,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<DateTime>(DateTime(0),
            instanceName: 'minimumSupport');
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File file =
            fs.file('/home/john/.minecraft/versions/1.99/1.99.json');
        await file.create(recursive: true);
        await file.writeAsString(dataParentJson);

        await task.init();
        expect(task.local!.id, '1.99');
      });

      test(
          'Should throw exception if the parent can\'t be found in the manifest and can\'t find version locally.',
          () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifest,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<DateTime>(DateTime(0),
            instanceName: 'minimumSupport');
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        bool errored = false;
        try {
          await task.init();
        } catch (_) {
          errored = true;
        }
        expect(errored, true);
      });

      test(
          'Should create child task with correct dependency if the parent is available in the manifest.',
          () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifestWithParent,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.init();
        expect(task.childTask!.dependency.id, '1.99');
      });

      test('Should add callback to copy data in the child task.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifestWithParent,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<DateTime>(DateTime(0),
            instanceName: 'minimumSupport');
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.init();
        task.childTask!.progress = 1;
        task.childTask!.exception = 'Error';
        task.childTask!.exceptionPhase = Phase.download;
        task.childTask!.result = dataParent;
        task.childTask!.notify();
        expect(task.progress, 1);
        expect(task.exception, 'Error');
        expect(task.exceptionPhase, Phase.download);
        expect(jsonEncode(task.result!.toJson()), dataParentJson);
        expect(jsonEncode(task.dependency.parent!.toJson()), dataParentJson);
      });

      test('Should add self callbacks to child task.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifestWithParent,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<DateTime>(DateTime(0),
            instanceName: 'minimumSupport');
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        bool called = false;
        task.callbacks.add(() => called = true);
        await task.init();
        task.childTask!.notify();
        expect(called, true);
      });

      test('Should not call self callbacks if cancelled.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            manifest: manifestWithParent,
            dependency: data,
            workingDir: '/home/john/.minecraft',
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<DateTime>(DateTime(0),
            instanceName: 'minimumSupport');
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        bool called = false;
        task.callbacks.add(() => called = true);
        await task.init();
        task.cancelled = true;
        task.childTask!.notify();
        expect(called, false);
      });
    });

    group('tryLoadCache', () {
      test('Should load the local version if available.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        task.local = dataParent;

        expect(await task.tryLoadCache, true);
        expect(jsonEncode(task.result!.toJson()), dataParentJson);
        expect(jsonEncode(task.dependency.parent!.toJson()), dataParentJson);
        expect(task.progress, 1);
      });

      test('Should load the child task\'s cache if available.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        task.childTask = MockVersionDownloadTask();
        when(task.childTask!.tryLoadCache).thenAnswer((_) async => true);
        when(task.childTask!.result).thenReturn(dataParent);
        when(task.childTask!.progress).thenReturn(1);

        expect(await task.tryLoadCache, true);
        expect(jsonEncode(task.result!.toJson()), dataParentJson);
        expect(jsonEncode(task.dependency.parent!.toJson()), dataParentJson);
        expect(task.progress, 1);
      });

      test('Should return false if no cache is available.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        expect(await task.tryLoadCache, false);
      });
    });

    group('download', () {
      test('Should call child task\'s download method if available.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        task.childTask = MockVersionDownloadTask();
        bool downloaded = false;
        when(task.childTask!.download())
            .thenAnswer((_) async => downloaded = true);
        await task.download();
        expect(downloaded, true);
      });
    });

    group('save', () {
      test('Save should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test(
            opHandle: (_, __) => throw Exception('Operation not supported'));
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.save();
        expect(task.exceptionPhase, Phase.save);
      });

      test('Save should correctly create the parent directories of the path.',
          () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.save();
        expect(await fs.directory('/home').exists(), true);
      });

      test('Save should correctly write the data to the path.', () async {
        final MockClient client = MockClient();
        final VersionParentDownloadTask task = VersionParentDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            manifest: manifest,
            dependency: data,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        task.result = dataParent;

        await task.save();

        File file = fs.file(
            '/home/john/.minecraft/${VersionDownloadTask.VERSION_PATH.replaceAll('{version}', '1.99')}');
        expect(await file.readAsString(), dataParentJson);
      });
    });
  });
}

VersionData get data => VersionData(
    ArgumentsData(null, null),
    AssetsIndex('2.0', 'x', 0, 0, ''),
    '2.0',
    0,
    CoreDownloads(null, null, null, null),
    '2.0',
    '1.99',
    [],
    'dev.dreta.smallworld.SmallWorld',
    null,
    DateTime(0),
    DateTime(0),
    VersionType.pending);

String get dataJson => jsonEncode(data.toJson());

VersionData get dataParent => VersionData(
    ArgumentsData(null, null),
    AssetsIndex('1.90', 'x', 0, 0, ''),
    '1.99',
    0,
    CoreDownloads(null, null, null, null),
    '1.99',
    null,
    [],
    'dev.dreta.smallworld.SmallWorld',
    null,
    DateTime(0),
    DateTime(0),
    VersionType.pending);

String get dataParentJson => jsonEncode(dataParent.toJson());

VersionManifest get manifest => VersionManifest(LatestVersion('2.0', '2.0'), [
      VersionInfo('2.0', VersionType.pending, 'https://dreta.dev/current',
          DateTime(0), DateTime(0))
    ]);

VersionManifest get manifestWithParent =>
    VersionManifest(LatestVersion('2.0', '2.0'), [
      VersionInfo('2.0', VersionType.pending, 'https://dreta.dev/current',
          DateTime(0), DateTime(0)),
      VersionInfo('1.99', VersionType.pending, 'https://dreta.dev/parent',
          DateTime(0), DateTime(0))
    ]);
