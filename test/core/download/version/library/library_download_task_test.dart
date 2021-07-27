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

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/task.dart';
import 'package:lilay/core/download/version/assets/friendly_download.dart';
import 'package:lilay/core/download/version/library/lib_download_info.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/version/library/library_download_task.dart';
import 'package:lilay/core/download/version/library/natives_mapping.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'library_download_task_test.mocks.dart';

const String ARTIF_CONTENT = 'Dreta';
const String NATIVE_CONTENT = 'twoexjayteen';
const String WRONG_ARTIF_CONTENT = 'YearPasts';
const String WRONG_NATIVE_CONTENT = 'aterD';
const String ARTIF_URL =
    'https://maven.dreta.dev/dev/dreta/lilay/1.0/lilay-1.0.jar';
const String ARTIF_HASH_URL =
    'https://maven.dreta.dev/dev/dreta/lilay/1.0/lilay-1.0.jar.sha1';
const String NATIVE_URL =
    'https://maven.dreta.dev/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar';

@GenerateMocks([ByteStream, Client, StreamedResponse, StreamSubscription])
void main() {
  group('LibraryDownloadTask', () {
    final Library library = Library(
        LibDownloadInfo(
            FriendlyDownload(
                'dev/dreta/lilay/1.0/lilay-1.0.jar',
                '062d0e3bfafabb22903e0afe00d0d535239cf179',
                ARTIF_CONTENT.codeUnits.length,
                ARTIF_URL),
            {
              'natives-windows': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      NATIVE_CONTENT.codeUnits.length,
                      NATIVE_URL)
                  .toJson(),
              'natives-macos': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      NATIVE_CONTENT.codeUnits.length,
                      NATIVE_URL)
                  .toJson(),
              'natives-linux': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      NATIVE_CONTENT.codeUnits.length,
                      NATIVE_URL)
                  .toJson()
            }),
        'dev.dreta:lilay:1.0',
        null,
        NativesMapping('natives-windows', 'natives-macos', 'natives-linux'),
        [Rule(RuleAction.allow, null, OSInfo('linux', 'x86_64', '5.13'))]);

    final Library libraryAlt = Library(
        null,
        'dev.dreta:lilay:1.0',
        'https://maven.dreta.dev',
        null,
        [Rule(RuleAction.allow, null, OSInfo('linux', 'x86_64', '5.13'))]);

    group('tryLoadCache', () {
      test('Should correctly load artifact if it exists and it is valid.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: libraryAlt,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File file = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
        await file.create(recursive: true);
        await file.writeAsString(ARTIF_CONTENT);

        mockArtifactHashRequest(client);

        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(String.fromCharCodes(task.result!), ARTIF_CONTENT);
      });

      test('Should correctly load native if it exists and it is valid.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: library,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File artifact = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
        await artifact.create(recursive: true);
        await artifact.writeAsString(ARTIF_CONTENT);

        final File native = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
        await native.create(recursive: true);
        await native.writeAsString(NATIVE_CONTENT);

        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(String.fromCharCodes(task.resultNative!), NATIVE_CONTENT);
      });

      test('Shouldn\'t load artifact if it exists but isn\'t valid.', () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: libraryAlt,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File file = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
        await file.create(recursive: true);
        await file.writeAsString(WRONG_ARTIF_CONTENT);

        mockArtifactHashRequest(client);

        expect(await task.tryLoadCache, false);
      });

      test('Shouldn\'t load native if it exists but isn\'t valid.', () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: library,
            client: client);
        final FileSystem fs = MemoryFileSystem.test();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        final File artifact = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
        await artifact.create(recursive: true);
        await artifact.writeAsString(ARTIF_CONTENT);

        final File native = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
        await native.create(recursive: true);
        await native.writeAsString(WRONG_NATIVE_CONTENT);

        expect(await task.tryLoadCache, false);
      });

      test('Should set the correct exception phase if an error is thrown.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '',
            workingDir: '/home/john/.minecraft',
            dependency: libraryAlt,
            client: client);
        final FileSystem fs = MemoryFileSystem.test(
            opHandle: (_, __) => throw Exception('Operation not supported'));
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        mockArtifactHashRequest(client);

        expect(await task.tryLoadCache, false);
        expect(task.exceptionPhase, Phase.loadCache);
      });
    });

    group('downloadArtifact', () {
      test(
          'Artifact download should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: libraryAlt, client: client);
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
        await task.downloadArtifact();
        expect(task.exceptionPhase, Phase.download);
      });

      test('Artifact download should correctly calculate the progress.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
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
        await task.downloadArtifact();
        expect(task.progress,
            1 / 10 / 2); // The progress should be 5% (half for artifact).
      });

      test('Artifact download should correctly set the result when finished.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(ARTIF_CONTENT.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](ARTIF_CONTENT.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadArtifact();
        expect(String.fromCharCodes(task.result!), ARTIF_CONTENT);
      });

      test('Artifact download should fail if the hash or size is wrong.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(WRONG_ARTIF_CONTENT.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](WRONG_ARTIF_CONTENT.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadArtifact();
        expect(task.exceptionPhase, Phase.download);
      });
    });

    group('downloadNative', () {
      test(
          'Native download should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
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
        await task.downloadNative();
        expect(task.exceptionPhase, Phase.download);
      });

      test('Native download should correctly calculate the progress.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
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
        await task.downloadNative();
        expect(
            task.progress,
            0.5 +
                1 / 10 / 2); // The progress should be 55% (half for artifact).
      });

      test('Native download should correctly set the result when finished.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(NATIVE_CONTENT.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](NATIVE_CONTENT.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadNative();
        expect(String.fromCharCodes(task.resultNative!), NATIVE_CONTENT);
      });

      test('Native download should fail if the hash or size is wrong.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
        final MockStreamedResponse resp = MockStreamedResponse();
        final MockByteStream bs = MockByteStream();
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        when(resp.stream).thenAnswer((_) => bs);
        when(resp.contentLength).thenReturn(WRONG_NATIVE_CONTENT.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](WRONG_NATIVE_CONTENT.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadNative();
        expect(task.exceptionPhase, Phase.download);
      });
    });

    group('save', () {
      test('Save should log an error with the correct exception phase.',
          () async {
        final MockClient client = MockClient();
        final LibraryDownloadTask task = LibraryDownloadTask(
            source: '', workingDir: '', dependency: library, client: client);
        final FileSystem fs = MemoryFileSystem.test(
            opHandle: (_, __) => throw Exception('Operation not supported'));
        await GetIt.I.reset();
        GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
        GetIt.I.registerSingleton<FileSystem>(fs);

        await task.save();
        expect(task.exceptionPhase, Phase.save);
      });
    });

    test(
        'Save should correctly create the parent directories of the artifact path.',
        () async {
      final MockClient client = MockClient();
      final LibraryDownloadTask task = LibraryDownloadTask(
          source: '',
          workingDir: '/home/john/.minecraft',
          dependency: library,
          client: client);
      final FileSystem fs = MemoryFileSystem.test();
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
      GetIt.I.registerSingleton<FileSystem>(fs);
      task.result = ARTIF_CONTENT.codeUnits;
      task.resultNative = NATIVE_CONTENT.codeUnits;

      await task.save();
      expect(
          await fs
              .directory('/home/john/.minecraft/libraries/dev/dreta/lilay')
              .exists(),
          true);
    });

    test(
        'Save should correctly create the parent directories of the native path.',
        () async {
      final MockClient client = MockClient();
      final LibraryDownloadTask task = LibraryDownloadTask(
          source: '',
          workingDir: '/home/john/.minecraft',
          dependency: library,
          client: client);
      final FileSystem fs = MemoryFileSystem.test();
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
      GetIt.I.registerSingleton<FileSystem>(fs);
      task.result = ARTIF_CONTENT.codeUnits;
      task.resultNative = NATIVE_CONTENT.codeUnits;

      await task.save();
      expect(
          await fs
              .directory(
                  '/home/john/.minecraft/libraries/dev/dreta/lilay-native')
              .exists(),
          true);
    });

    test('Save should correctly write the artifact data to the path.',
        () async {
      final MockClient client = MockClient();
      final LibraryDownloadTask task = LibraryDownloadTask(
          source: '',
          workingDir: '/home/john/.minecraft',
          dependency: library,
          client: client);
      final FileSystem fs = MemoryFileSystem.test();
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
      GetIt.I.registerSingleton<FileSystem>(fs);
      task.result = ARTIF_CONTENT.codeUnits;
      task.resultNative = NATIVE_CONTENT.codeUnits;

      await task.save();

      File file = fs.file(
          '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
      expect(await file.readAsString(), ARTIF_CONTENT);
    });

    test('Save should correctly write the native data to the path.', () async {
      final MockClient client = MockClient();
      final LibraryDownloadTask task = LibraryDownloadTask(
          source: '',
          workingDir: '/home/john/.minecraft',
          dependency: library,
          client: client);
      final FileSystem fs = MemoryFileSystem.test();
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger('Lilay'));
      GetIt.I.registerSingleton<FileSystem>(fs);
      task.result = ARTIF_CONTENT.codeUnits;
      task.resultNative = NATIVE_CONTENT.codeUnits;

      await task.save();

      File file = fs.file(
          '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
      expect(await file.readAsString(), NATIVE_CONTENT);
    });
  });
}

void mockArtifactHashRequest(MockClient client) {
  when(client.get(Uri.parse(ARTIF_HASH_URL))).thenAnswer(
      (_) async => Response('062d0e3bfafabb22903e0afe00d0d535239cf179', 200));
}
