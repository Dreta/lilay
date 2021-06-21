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
import 'package:lilay/core/download/version/assets/assets_index.dart';
import 'package:lilay/core/download/version/assets/core_downloads.dart';
import 'package:lilay/core/download/version/library/library.dart';
import 'package:lilay/core/download/versions/version_info.dart';

import 'arguments/arguments_data.dart';
import 'version_parent_download_task.dart';

part 'version_data.g.dart';

/// Represents the manifest for a version in Minecraft.
///
/// Found under [working directory]/versions/[version]/[version].json
@JsonSerializable(explicitToJson: true, ignoreUnannotated: true)
class VersionData {
  /// The loaded parent [VersionData] from [inheritsFrom].
  ///
  /// [VersionParentDownloadTask] will populate this field when downloading
  /// the parent of this version.
  VersionData? parent;

  // Self fields are raw fields from the JSON.
  // They do not factor in the parent of this version. Please use
  // the getters instead.
  @JsonKey(name: 'arguments')
  ArgumentsData? selfArguments;
  @JsonKey(name: 'assetIndex')
  AssetsIndex? selfAssetIndex;
  @JsonKey(name: 'assets')
  String? selfAssets;
  @JsonKey(name: 'complianceLevel')
  int? selfComplianceLevel;
  @JsonKey(name: 'downloads')
  CoreDownloads? selfDownloads;
  @JsonKey(name: 'id')
  String selfID;
  @JsonKey(name: 'inheritsFrom')
  String? selfInheritsFrom;
  @JsonKey(name: 'libraries')
  List<Library>? selfLibraries;

  // TODO support logging
  @JsonKey(name: 'mainClass')
  String? selfMainClass;

  @JsonKey(name: 'minecraftArguments')
  String?
      selfMinecraftArguments; // Legacy versions (I'm not entirely sure when this will appear instead of [arguments])

  @JsonKey(name: 'releaseTime')
  DateTime? selfReleaseTime;
  @JsonKey(name: 'time')
  DateTime? selfTime;
  @JsonKey(name: 'type')
  VersionType? selfType;

  VersionData(
      ArgumentsData? selfArguments,
      AssetsIndex? selfAssetIndex,
      String? selfAssets,
      int? selfComplianceLevel,
      CoreDownloads? selfDownloads,
      String selfID,
      String? selfInheritsFrom,
      List<Library>? selfLibraries,
      String? selfMainClass,
      String? selfMinecraftArguments,
      DateTime? selfReleaseTime,
      DateTime? selfTime,
      VersionType? selfType)
      : this.selfArguments = selfArguments,
        this.selfAssetIndex = selfAssetIndex,
        this.selfAssets = selfAssets,
        this.selfComplianceLevel = selfComplianceLevel,
        this.selfDownloads = selfDownloads,
        this.selfID = selfID,
        this.selfInheritsFrom = selfInheritsFrom,
        this.selfLibraries = selfLibraries,
        this.selfMainClass = selfMainClass,
        this.selfMinecraftArguments = selfMinecraftArguments,
        this.selfReleaseTime = selfReleaseTime,
        this.selfTime = selfTime,
        this.selfType = selfType {
    if (selfInheritsFrom == null) {
      // If we do not have a parent, then certain fields must be present.
      assert(selfAssets != null);
      assert(selfDownloads != null);
      assert(selfLibraries != null);
      assert(selfMainClass != null);
      assert(selfReleaseTime != null);
      assert(selfTime != null);
      assert(selfType != null);
    }
  }

  /// Get the arguments of this version, inheriting from the parent.
  ///
  /// This getter will merge the arguments object of the two versions
  /// through a simple substitution method.
  ///
  /// Example:
  ///   Parent Arguments:
  ///     JVM: [a, b, c]
  ///     Game: [a, b, c]
  ///   Self Arguments:
  ///     JVM: [a, b, c, d]
  ///     Game: null
  /// Result:
  ///   JVM: [a, b, c, d]
  ///   Game: [a, b, c]
  ArgumentsData? get arguments {
    if (parent == null) {
      return selfArguments;
    }
    if (selfArguments == null) {
      return parent!.arguments;
    }
    // TODO Do we really want to use substitution, instead of merging for arguments?
    return ArgumentsData(
        selfArguments!.jvm == null
            ? parent!.arguments?.jvm
            : selfArguments!.jvm,
        selfArguments!.game == null
            ? parent!.arguments?.game
            : selfArguments!.game);
  }

  /// Get the asset index of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's asset index if BOTH the parent
  /// is available AND the self asset index is NOT available.
  AssetsIndex? get assetIndex {
    if (parent != null && selfAssetIndex == null) {
      return parent!.assetIndex;
    }
    return selfAssetIndex;
  }

  /// Get the assets ID of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's assets ID if BOTH the parent
  /// is available AND the self assets ID is NOT available.
  String get assets {
    if (parent != null && selfAssets == null) {
      return parent!.assets;
    }
    return selfAssets!;
  }

  /// Get the compliance level of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's compliance level if BOTH the parent
  /// is available AND the self compliance level is NOT available.
  int? get complianceLevel {
    if (parent != null && selfComplianceLevel == null) {
      return parent!.complianceLevel;
    }
    return selfComplianceLevel;
  }

  /// Get the downloads of this version, inheriting from the parent.
  ///
  /// This getter will merge the downloads object of the two versions
  /// through a simple substitution method.
  ///
  /// Example:
  ///   Parent Downloads:
  ///     Client: never
  ///     Client Mappings: null
  ///     Server: gonna
  ///     Server Mappings: null
  ///   Self Downloads:
  ///     Client: give
  ///     Client Mappings: up
  ///     Server: null
  ///     Server Mappings: null
  /// Result:
  ///   Client: give
  ///   Client Mappings: up
  ///   Server: gonna
  ///   Server Mappings: null
  CoreDownloads get downloads {
    if (parent == null) {
      return selfDownloads!;
    }
    if (selfDownloads == null) {
      return parent!.downloads;
    }
    return CoreDownloads(
        selfDownloads!.client == null
            ? parent!.downloads.client
            : selfDownloads!.client,
        selfDownloads!.clientMappings == null
            ? parent!.downloads.clientMappings
            : selfDownloads!.clientMappings,
        selfDownloads!.server == null
            ? parent!.downloads.server
            : selfDownloads!.server,
        selfDownloads!.serverMappings == null
            ? parent!.downloads.serverMappings
            : selfDownloads!.serverMappings);
  }

  /// Get the ID of this version.
  String get id => selfID;

  /// Get the parent ID of this version.
  ///
  /// For the loaded parent object, see [parent].
  String? get inheritsFrom => selfInheritsFrom;

  /// Get the libraries of this version, inheriting from the parent.
  ///
  /// This getter will merge the libraries of the two versions
  /// by combining them together in one list.
  ///
  /// Example:
  ///   Parent Libraries: a, b, c, d
  ///   Self Libraries: e, f, g
  ///   Result: a, b, c, d, e, f, g
  List<Library> get libraries {
    if (parent == null) {
      return selfLibraries!;
    }
    if (selfLibraries == null) {
      return parent!.libraries;
    }
    List<Library> libraries = [];
    libraries.addAll(selfLibraries ?? []);
    libraries.addAll(parent!.libraries);
    return libraries;
  }

  /// Get the main class of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's main class if BOTH the parent
  //   /// is available AND the self main class is NOT available.
  String get mainClass {
    if (parent != null && selfMainClass == null) {
      return parent!.mainClass;
    }
    return selfMainClass!;
  }

  /// Get the Minecraft arguments of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's Minecraft arguments if BOTH the parent
  /// is available AND the self Minecraft arguments is NOT available.
  String? get minecraftArguments {
    if (parent != null && selfMinecraftArguments == null) {
      return parent!.minecraftArguments;
    }
    return selfMinecraftArguments!;
  }

  /// Get the release time of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's release time if BOTH the parent
  /// is available AND the self release time is NOT available.
  DateTime get releaseTime {
    if (parent != null && selfReleaseTime == null) {
      return parent!.releaseTime;
    }
    return selfReleaseTime!;
  }

  /// Get the time (what is this?) of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's time if BOTH the parent
  /// is available AND the self time is NOT available.
  DateTime get time {
    if (parent != null && selfTime == null) {
      return parent!.time;
    }
    return selfTime!;
  }

  /// Get the type of this version, inheriting from the parent.
  ///
  /// This getter will return the parent's type if BOTH the parent
  /// is available AND the self type is NOT available.
  VersionType get type {
    if (parent != null && selfType == null) {
      return parent!.type;
    }
    return selfType!;
  }

  Map<String, dynamic> toJson() => _$VersionDataToJson(this);

  factory VersionData.fromJson(Map<String, dynamic> json) =>
      _$VersionDataFromJson(json);
}
