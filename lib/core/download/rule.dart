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

import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:lilay/core/auth/account.dart';
import 'package:lilay/core/profile/profile.dart';
import 'package:lilay/utils.dart';
import 'package:system_info/system_info.dart';

part 'rule.g.dart';

@JsonSerializable(explicitToJson: true)
class Rule {
  RuleAction action;
  FeatureSet? features;
  OSInfo? os;

  Rule(RuleAction action, FeatureSet? features, OSInfo? os)
      : this.action = action,
        this.features = features,
        this.os = os;

  static bool multiRulesApplicable(
      List<Rule> rules, Account? account, Profile? profile) {
    bool applicability = rules.isEmpty;

    for (Rule rule in rules) {
      if (rule.action == RuleAction.allow) {
        if (rule.applicable(account, profile)) {
          applicability = true;
        }
      } else {
        if (rule.applicable(account, profile)) {
          return false;
        }
      }
    }

    return applicability;
  }

  applicable(Account? account, Profile? profile) {
    bool featuresCompatible =
        features != null ? features!.applicable(account, profile) : true;
    bool osCompatible = os != null ? os!.applicable() : true;
    return featuresCompatible && osCompatible;
  }

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

  Map<String, dynamic> toJson() => _$RuleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FeatureSet {
  @JsonKey(name: 'is_demo_user')
  bool? isDemoUser;

  @JsonKey(name: 'has_custom_resolution')
  bool? hasCustomResolution;

  FeatureSet(bool? isDemoUser, bool? hasCustomResolution)
      : this.isDemoUser = isDemoUser,
        this.hasCustomResolution = hasCustomResolution;

  bool applicable(Account? account, Profile? profile) {
    // This is truly spaghetti code.
    if (account == null && profile == null) {
      return true;
    }
    if (isDemoUser ?? false) {
      return false; // Never use demo mode
    }
    if (profile != null &&
        (hasCustomResolution ?? false) &&
        (profile.resolutionWidth != null || profile.resolutionHeight != null)) {
      return true;
    }
    return false;
  }

  factory FeatureSet.fromJson(Map<String, dynamic> json) =>
      _$FeatureSetFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureSetToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OSInfo {
  String name;
  String? arch;
  String? version;

  OSInfo(String name, String? arch, String? version)
      : this.name = name,
        this.arch = arch,
        this.version = version;

  bool applicable() {
    // Check for OS name applicability
    bool nameApplicable = name == getOSName();

    // Check for architecture compatibility
    bool architectureCompatible = true;
    if (arch != null) {
      architectureCompatible = arch! == SysInfo.kernelArchitecture;
    }

    bool versionCompatible = true;
    // Check for version applicability
    if (version != null) {
      versionCompatible =
          RegExp(version!).hasMatch(Platform.operatingSystemVersion);
    }

    return nameApplicable && architectureCompatible && versionCompatible;
  }

  factory OSInfo.fromJson(Map<String, dynamic> json) => _$OSInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OSInfoToJson(this);
}

enum RuleAction { allow, disallow }
