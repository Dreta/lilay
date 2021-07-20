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

import 'dart:async';
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
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'version_download_task_test.mocks.dart';

@GenerateMocks([ByteStream, Client, StreamedResponse, StreamSubscription])
void main() {
  group('VersionDownloadTask', () {
    final VersionData data = VersionData(
        ArgumentsData(null, null),
        AssetsIndex('2.0', 'x', 0, 0, ''),
        '2.0',
        0,
        CoreDownloads(null, null, null, null),
        '2.0',
        null,
        [],
        'dev.dreta.smallworld.SmallWorld',
        null,
        DateTime.now(),
        DateTime.now(),
        VersionType.pending);
    final VersionInfo info = VersionInfo(
        '2.0',
        VersionType.pending,
        'https://dreta.dev/06/062d0e3bfafabb22903e0afe00d0d535239cf179',
        DateTime.now(),
        DateTime.now());
    final String dataJson = jsonEncode(data.toJson());

    group('tryLoadCache', () {
      test('Cache loading should succeed if the file exist.', () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: info,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File file =
            fs.file('/home/john/.minecraft/versions/2.0/2.0.json');
        await file.create(recursive: true);
        await file.writeAsString(dataJson);

        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(jsonEncode(task.result!.toJson()), dataJson);
      });

      test('Cache loading should fail if the file isn\'t cached.', () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: info,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        expect(await task.tryLoadCache, false);
      });

      test(
          'Cache loading should set the correct exception phase if an error is thrown.',
          () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: info,
            client: client);
        final FileSystem fs = MemoryFileSystem.test(
            opHandle: (_, __) => throw Exception('Operation not supported'));
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        expect(await task.tryLoadCache, false);
        expect(task.exceptionPhase, Phase.loadCache);
      });
    });

    group('download', () {
      test('Download should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '', workingDir: '', dependency: info, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(10);
        when(bs.handleError(any, test: anyNamed('test')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0]('Error');
          return bs;
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.download();
        expect(task.exceptionPhase, Phase.download);
      });

      test('Download should correctly calculate the progress.', () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '', workingDir: '', dependency: info, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength)
            .thenReturn(10); // The length of the response is 10.
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](
              [1]); // The length of the download data is 1.
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.download();
        expect(task.progress, 1 / 10); // The progress should be 10%.
      });

      test('Download should correctly set the result when finished.', () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '', workingDir: '', dependency: info, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(dataJson.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](dataJson.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.download();
        expect(jsonEncode(task.result!.toJson()), dataJson);
      });
    });

    group('save', () {
      test('Save should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final VersionDownloadTask task = VersionDownloadTask(
            source: '', workingDir: '', dependency: info, client: client);
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
        final VersionDownloadTask task = VersionDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: info,
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
        final VersionDownloadTask task = VersionDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: info,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        task.result = data;

        await task.save();

        File file = fs.file(
            '/home/john/.minecraft/${VersionDownloadTask.VERSION_PATH.replaceAll('{version}', '2.0')}');
        expect(await file.readAsString(), dataJson);
      });
    });
  });
}
