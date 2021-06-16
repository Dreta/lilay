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

import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/core/download/rule.dart';
import 'package:lilay/core/download/version/library/natives_mapping.dart';

import 'lib_download_info.dart';

part 'library.g.dart';

@JsonSerializable(explicitToJson: true)
class Library {
  LibDownloadInfo? downloads;
  String name;
  String? url;
  NativesMapping? natives;
  List<Rule> rules;

  Library(LibDownloadInfo? downloads, String name, String? url,
      NativesMapping? natives, List<Rule>? rules)
      : this.downloads = downloads,
        this.name = name,
        this.url = url,
        this.natives = natives,
        this.rules = rules ?? [];

  Map<String, dynamic> toJson() => _$LibraryToJson(this);

  factory Library.fromJson(Map<String, dynamic> json) =>
      _$LibraryFromJson(json);
}
