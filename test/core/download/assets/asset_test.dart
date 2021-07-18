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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lilay/core/download/assets/asset.dart';

void main() {
  group('Asset', () {
    test('Path should be correct.', () {
      // Challenge: The hash is in SHA1. Can you guess what it is?
      final Asset asset =
          Asset('062d0e3bfafabb22903e0afe00d0d535239cf179', 0x6cc9ba8e);
      final String sep = Platform.pathSeparator;
      expect(asset.path(''),
          '${sep}assets${sep}objects$sep${asset.hash.substring(0, 2)}$sep${asset.hash}');
    });

    test('URL should be correct.', () {
      final Asset asset =
          Asset('062d0e3bfafabb22903e0afe00d0d535239cf179', 0x6cc9ba8e);
      expect(asset.url(''), '/${asset.hash.substring(0, 2)}/${asset.hash}');
    });
  });
}
