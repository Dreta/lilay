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

final String artifactContent = 'Dreta';
final String nativeContent = 'twoexjayteen';
final String wrongArtifContent = 'YearPasts';
final String wrongNativeContent = 'aterD';
final String artifactUrl =
    'https://maven.dreta.dev/dev/dreta/lilay/1.0/lilay-1.0.jar';
final String artifactHashUrl =
    'https://maven.dreta.dev/dev/dreta/lilay/1.0/lilay-1.0.jar.sha1';
final String nativeUrl =
    'https://maven.dreta.dev/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar';

@GenerateMocks([ByteStream, Client, StreamedResponse, StreamSubscription])
void main() {
  group('LibraryDownloadTask', () {
    final Library library = Library(
        LibDownloadInfo(
            FriendlyDownload(
                'dev/dreta/lilay/1.0/lilay-1.0.jar',
                '062d0e3bfafabb22903e0afe00d0d535239cf179',
                artifactContent.codeUnits.length,
                artifactUrl),
            {
              'natives-windows': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      nativeContent.codeUnits.length,
                      nativeUrl)
                  .toJson(),
              'natives-macos': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      nativeContent.codeUnits.length,
                      nativeUrl)
                  .toJson(),
              'natives-linux': FriendlyDownload(
                      'dev/dreta/lilay-native/1.0/lilay-native-1.0.jar',
                      'e0267d156830d0a04069cb091f0e2d811a738358',
                      nativeContent.codeUnits.length,
                      nativeUrl)
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
        await file.writeAsString(artifactContent);

        mockArtifactHashRequest(client);

        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(String.fromCharCodes(task.result!), artifactContent);
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
        await artifact.writeAsString(artifactContent);

        final File native = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
        await native.create(recursive: true);
        await native.writeAsString(nativeContent);

        expect(await task.tryLoadCache, true);
        expect(task.progress, 1);
        expect(String.fromCharCodes(task.resultNative!), nativeContent);
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
        await file.writeAsString(wrongArtifContent);

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
        await artifact.writeAsString(artifactContent);

        final File native = fs.file(
            '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
        await native.create(recursive: true);
        await native.writeAsString(wrongNativeContent);

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
        when(resp.contentLength).thenReturn(artifactContent.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](artifactContent.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadArtifact();
        expect(String.fromCharCodes(task.result!), artifactContent);
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
        when(resp.contentLength).thenReturn(wrongArtifContent.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](wrongArtifContent.codeUnits);
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
        when(resp.contentLength).thenReturn(nativeContent.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](nativeContent.codeUnits);
          return MockStreamSubscription();
        });
        when(client.send(any)).thenAnswer((_) async => resp);
        await task.downloadNative();
        expect(String.fromCharCodes(task.resultNative!), nativeContent);
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
        when(resp.contentLength).thenReturn(wrongNativeContent.length);
        when(bs.handleError(any, test: anyNamed('test'))).thenAnswer((_) => bs);
        when(bs.listen(any,
                onError: anyNamed('onError'),
                onDone: anyNamed('onDone'),
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((invocation) {
          invocation.positionalArguments[0](wrongNativeContent.codeUnits);
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
      task.result = artifactContent.codeUnits;
      task.resultNative = nativeContent.codeUnits;

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
      task.result = artifactContent.codeUnits;
      task.resultNative = nativeContent.codeUnits;

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
      task.result = artifactContent.codeUnits;
      task.resultNative = nativeContent.codeUnits;

      await task.save();

      File file = fs.file(
          '/home/john/.minecraft/libraries/dev/dreta/lilay/1.0/lilay-1.0.jar');
      expect(await file.readAsString(), artifactContent);
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
      task.result = artifactContent.codeUnits;
      task.resultNative = nativeContent.codeUnits;

      await task.save();

      File file = fs.file(
          '/home/john/.minecraft/libraries/dev/dreta/lilay-native/1.0/lilay-native-1.0.jar');
      expect(await file.readAsString(), nativeContent);
    });
  });
}

void mockArtifactHashRequest(MockClient client) {
  when(client.get(Uri.parse(artifactHashUrl))).thenAnswer(
      (_) async => Response('062d0e3bfafabb22903e0afe00d0d535239cf179', 200));
}
