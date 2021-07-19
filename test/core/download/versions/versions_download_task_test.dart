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
import 'package:lilay/core/download/versions/latest_version.dart';
import 'package:lilay/core/download/versions/version_info.dart';
import 'package:lilay/core/download/versions/version_manifest.dart';
import 'package:lilay/core/download/versions/versions_download_task.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'versions_download_task_test.mocks.dart';

@GenerateMocks([ByteStream, Client, StreamedResponse, StreamSubscription])
void main() {
  group('VersionsDownloadTask', () {
    // All tests are based on this manifest.
    final VersionManifest manifest = VersionManifest(
        LatestVersion('1.17.1', '1.17.1'), [
      VersionInfo(
          '1.17.1', VersionType.release, '', DateTime.now(), DateTime.now())
    ]);
    String mfJson = jsonEncode(manifest.toJson());

    group('tryLoadCache', () {
      test('Cache loading should fail if internet is available.', () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(MemoryFileSystem.test());
        when(client.send(any)).thenAnswer((_) async => MockStreamedResponse());
        expect(await task.tryLoadCache, false);
      });

      test(
          'Cache loading should succeed if internet isn\'t available, and the manifest is cached.',
          () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        File file = fs.file('/${VersionsDownloadTask.MANIFEST_PATH}');
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode(manifest.toJson()));

        when(client.send(any)).thenThrow(Exception('Disconnected'));
        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(
            jsonEncode(task.result!.toJson()), jsonEncode(manifest.toJson()));
      });

      test(
          'Cache loading should fail if internet isn\'t available, and the manifest isn\'t cached.',
          () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        when(client.send(any)).thenThrow(Exception('Disconnected'));
        expect(await task.tryLoadCache, false);
      });
    });

    group('download', () {
      test('Download should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
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
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(10);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0]([1]);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.download();
        expect(task.progress, 1 / 10);
      });

      test('Download should correctly set the result when finished.', () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(mfJson.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](mfJson.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.download();
        expect(jsonEncode(task.result!.toJson()), mfJson);
      });
    });

    group('save', () {
      test('Save should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task =
            VersionsDownloadTask(source: '', workingDir: '', client: client);
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
        final VersionsDownloadTask task = VersionsDownloadTask(
            source: '', workingDir: '/home/john/.minecraft', client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.save();
        expect(await fs.directory('/home').exists(), true);
      });

      test('Save should correctly write the manifest to the path.', () async {
        final MockClient client = MockClient();
        final VersionsDownloadTask task = VersionsDownloadTask(
            source: '', workingDir: '/home/john/.minecraft', client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);
        task.result = manifest;

        await task.save();

        File file = fs.file(
            '/home/john/.minecraft/${VersionsDownloadTask.MANIFEST_PATH}');
        expect(await file.readAsString(), mfJson);
      });
    });
  });
}
