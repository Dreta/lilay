/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Gabriel Leen / Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later dependency.
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

import 'package:flutter_test/flutter_test.dart';
import 'package:lilay/core/download/version/library/artifact.dart';

void main() {
  group('Artifact', () {
    test('Correctly parses raw artifact name into different parts.', () {
      final Artifact artifact = Artifact('dev.dreta:lilay:1.0');
      expect(artifact.groupId, 'dev.dreta');
      expect(artifact.artifactId, 'lilay');
      expect(artifact.version, '1.0');
    });

    test('URL functions correctly.', () {
      final Artifact artifact = Artifact('dev.dreta:lilay:1.0');
      expect(artifact.url(''), '/dev/dreta/lilay/1.0/lilay-1.0.jar');
    });

    test('URLHash functions correctly.', () {
      final Artifact artifact = Artifact('dev.dreta:lilay:1.0');
      expect(artifact.urlHash(''), '/dev/dreta/lilay/1.0/lilay-1.0.jar.sha1');
    });

    test('Path functions correctly.', () {
      final Artifact artifact = Artifact('dev.dreta:lilay:1.0');
      expect(artifact.path('').replaceAll(Platform.pathSeparator, '/'),
          '/dev/dreta/lilay/1.0/lilay-1.0.jar');
    });
  });
}
