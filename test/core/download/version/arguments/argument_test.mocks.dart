// Mocks generated by Mockito 5.0.10 from annotations
// in lilay/test/core/download/version/arguments/argument_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:ui' as _i11;

import 'package:file/src/interface/file.dart' as _i10;
import 'package:http/src/client.dart' as _i6;
import 'package:lilay/core/auth/account.dart' as _i4;
import 'package:lilay/core/auth/auth_provider.dart' as _i2;
import 'package:lilay/core/configuration/core/core_config.dart' as _i8;
import 'package:lilay/core/configuration/core/types.dart' as _i9;
import 'package:lilay/core/download/version/arguments/arguments_data.dart'
    as _i13;
import 'package:lilay/core/download/version/assets/assets_index.dart' as _i14;
import 'package:lilay/core/download/version/assets/core_downloads.dart' as _i3;
import 'package:lilay/core/download/version/library/library.dart' as _i15;
import 'package:lilay/core/download/version/version_data.dart' as _i12;
import 'package:lilay/core/download/versions/version_info.dart' as _i16;
import 'package:lilay/core/profile/profile.dart' as _i7;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeAuthProvider extends _i1.Fake implements _i2.AuthProvider {}

class _FakeCoreDownloads extends _i1.Fake implements _i3.CoreDownloads {}

class _FakeDateTime extends _i1.Fake implements DateTime {
  @override
  String toString() => super.toString();
}

/// A class which mocks [Account].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccount extends _i1.Mock implements _i4.Account {
  MockAccount() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get username =>
      (super.noSuchMethod(Invocation.getter(#username), returnValue: '')
          as String);
  @override
  String get accessToken =>
      (super.noSuchMethod(Invocation.getter(#accessToken), returnValue: '')
          as String);
  @override
  String get profileName =>
      (super.noSuchMethod(Invocation.getter(#profileName), returnValue: '')
          as String);
  @override
  String get uuid =>
      (super.noSuchMethod(Invocation.getter(#uuid), returnValue: '') as String);
  @override
  String get type =>
      (super.noSuchMethod(Invocation.getter(#type), returnValue: '') as String);
  @override
  bool get requiresReauth => (super
          .noSuchMethod(Invocation.getter(#requiresReauth), returnValue: false)
      as bool);
  @override
  bool get selected =>
      (super.noSuchMethod(Invocation.getter(#selected), returnValue: false)
          as bool);
  @override
  bool get paid =>
      (super.noSuchMethod(Invocation.getter(#paid), returnValue: false)
          as bool);
  @override
  set selected(bool? sel) =>
      super.noSuchMethod(Invocation.setter(#selected, sel),
          returnValueForMissingStub: null);
  @override
  _i2.AuthProvider get authProvider =>
      (super.noSuchMethod(Invocation.getter(#authProvider),
          returnValue: _FakeAuthProvider()) as _i2.AuthProvider);
  @override
  _i5.Future<void> refresh(_i6.Client? client) =>
      (super.noSuchMethod(Invocation.method(#refresh, [client]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> updatePaymentStatus(_i6.Client? client) =>
      (super.noSuchMethod(Invocation.method(#updatePaymentStatus, [client]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> invalidate(_i6.Client? client) =>
      (super.noSuchMethod(Invocation.method(#invalidate, [client]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i5.Future<void>);
  @override
  Map<String, dynamic> toJson() =>
      (super.noSuchMethod(Invocation.method(#toJson, []),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
}

/// A class which mocks [Profile].
///
/// See the documentation for Mockito's code generation for more information.
class MockProfile extends _i1.Mock implements _i7.Profile {
  MockProfile() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: 0) as int);

  @override
  set id(int? _id) => super.noSuchMethod(Invocation.setter(#id, _id),
      returnValueForMissingStub: null);

  @override
  String get name =>
      (super.noSuchMethod(Invocation.getter(#name), returnValue: '') as String);

  @override
  set name(String? _name) => super.noSuchMethod(Invocation.setter(#name, _name),
      returnValueForMissingStub: null);

  @override
  String get version =>
      (super.noSuchMethod(Invocation.getter(#version), returnValue: '')
          as String);
  @override
  set version(String? _version) =>
      super.noSuchMethod(Invocation.setter(#version, _version),
          returnValueForMissingStub: null);
  @override
  set gameDirectory(String? _gameDirectory) =>
      super.noSuchMethod(Invocation.setter(#gameDirectory, _gameDirectory),
          returnValueForMissingStub: null);
  @override
  set resolutionWidth(int? _resolutionWidth) =>
      super.noSuchMethod(Invocation.setter(#resolutionWidth, _resolutionWidth),
          returnValueForMissingStub: null);
  @override
  set resolutionHeight(int? _resolutionHeight) => super.noSuchMethod(
      Invocation.setter(#resolutionHeight, _resolutionHeight),
      returnValueForMissingStub: null);
  @override
  set javaExecutable(String? _javaExecutable) =>
      super.noSuchMethod(Invocation.setter(#javaExecutable, _javaExecutable),
          returnValueForMissingStub: null);
  @override
  String get jvmArguments =>
      (super.noSuchMethod(Invocation.getter(#jvmArguments), returnValue: '')
          as String);
  @override
  set jvmArguments(String? _jvmArguments) =>
      super.noSuchMethod(Invocation.setter(#jvmArguments, _jvmArguments),
          returnValueForMissingStub: null);
  @override
  String get gameArguments =>
      (super.noSuchMethod(Invocation.getter(#gameArguments), returnValue: '')
          as String);
  @override
  set gameArguments(String? _gameArguments) =>
      super.noSuchMethod(Invocation.setter(#gameArguments, _gameArguments),
          returnValueForMissingStub: null);
  @override
  bool get selected =>
      (super.noSuchMethod(Invocation.getter(#selected), returnValue: false)
          as bool);
  @override
  set selected(bool? _selected) =>
      super.noSuchMethod(Invocation.setter(#selected, _selected),
          returnValueForMissingStub: null);
  @override
  Map<String, dynamic> toJson() =>
      (super.noSuchMethod(Invocation.method(#toJson, []),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
}

/// A class which mocks [CoreConfig].
///
/// See the documentation for Mockito's code generation for more information.
class MockCoreConfig extends _i1.Mock implements _i8.CoreConfig {
  MockCoreConfig() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get workingDirectory =>
      (super.noSuchMethod(Invocation.getter(#workingDirectory), returnValue: '')
          as String);
  @override
  set workingDirectory(String? _workingDirectory) => super.noSuchMethod(
      Invocation.setter(#workingDirectory, _workingDirectory),
      returnValueForMissingStub: null);
  @override
  _i9.BackgroundType get backgroundType =>
      (super.noSuchMethod(Invocation.getter(#backgroundType),
          returnValue: _i9.BackgroundType.asset) as _i9.BackgroundType);
  @override
  set backgroundType(_i9.BackgroundType? _backgroundType) =>
      super.noSuchMethod(Invocation.setter(#backgroundType, _backgroundType),
          returnValueForMissingStub: null);
  @override
  set backgroundImage(String? _backgroundImage) =>
      super.noSuchMethod(Invocation.setter(#backgroundImage, _backgroundImage),
          returnValueForMissingStub: null);
  @override
  String get preferredLoginType => (super
          .noSuchMethod(Invocation.getter(#preferredLoginType), returnValue: '')
      as String);
  @override
  set preferredLoginType(String? _preferredLoginType) => super.noSuchMethod(
      Invocation.setter(#preferredLoginType, _preferredLoginType),
      returnValueForMissingStub: null);
  @override
  int get accent =>
      (super.noSuchMethod(Invocation.getter(#accent), returnValue: 0) as int);
  @override
  set accent(int? _accent) =>
      super.noSuchMethod(Invocation.setter(#accent, _accent),
          returnValueForMissingStub: null);
  @override
  _i9.DarkModeType get darkMode =>
      (super.noSuchMethod(Invocation.getter(#darkMode),
          returnValue: _i9.DarkModeType.light) as _i9.DarkModeType);
  @override
  set darkMode(_i9.DarkModeType? _darkMode) =>
      super.noSuchMethod(Invocation.setter(#darkMode, _darkMode),
          returnValueForMissingStub: null);
  @override
  String get metaSource =>
      (super.noSuchMethod(Invocation.getter(#metaSource), returnValue: '')
          as String);
  @override
  set metaSource(String? _metaSource) =>
      super.noSuchMethod(Invocation.setter(#metaSource, _metaSource),
          returnValueForMissingStub: null);
  @override
  String get assetsSource =>
      (super.noSuchMethod(Invocation.getter(#assetsSource), returnValue: '')
          as String);
  @override
  set assetsSource(String? _assetsSource) =>
      super.noSuchMethod(Invocation.setter(#assetsSource, _assetsSource),
          returnValueForMissingStub: null);
  @override
  String get librariesSource =>
      (super.noSuchMethod(Invocation.getter(#librariesSource), returnValue: '')
          as String);
  @override
  set librariesSource(String? _librariesSource) =>
      super.noSuchMethod(Invocation.setter(#librariesSource, _librariesSource),
          returnValueForMissingStub: null);
  @override
  String get coreSource =>
      (super.noSuchMethod(Invocation.getter(#coreSource), returnValue: '')
          as String);
  @override
  set coreSource(String? _coreSource) =>
      super.noSuchMethod(Invocation.setter(#coreSource, _coreSource),
          returnValueForMissingStub: null);
  @override
  bool get showSnapshots =>
      (super.noSuchMethod(Invocation.getter(#showSnapshots), returnValue: false)
          as bool);
  @override
  set showSnapshots(bool? _showSnapshots) =>
      super.noSuchMethod(Invocation.setter(#showSnapshots, _showSnapshots),
          returnValueForMissingStub: null);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  dynamic write(_i10.File? file) =>
      super.noSuchMethod(Invocation.method(#write, [file]));
  @override
  Map<String, dynamic> toJson() =>
      (super.noSuchMethod(Invocation.method(#toJson, []),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
  @override
  void addListener(_i11.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i11.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [VersionData].
///
/// See the documentation for Mockito's code generation for more information.
class MockVersionData extends _i1.Mock implements _i12.VersionData {
  MockVersionData() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set parent(_i12.VersionData? _parent) =>
      super.noSuchMethod(Invocation.setter(#parent, _parent),
          returnValueForMissingStub: null);
  @override
  set selfArguments(_i13.ArgumentsData? _selfArguments) =>
      super.noSuchMethod(Invocation.setter(#selfArguments, _selfArguments),
          returnValueForMissingStub: null);
  @override
  set selfAssetIndex(_i14.AssetsIndex? _selfAssetIndex) =>
      super.noSuchMethod(Invocation.setter(#selfAssetIndex, _selfAssetIndex),
          returnValueForMissingStub: null);
  @override
  set selfAssets(String? _selfAssets) =>
      super.noSuchMethod(Invocation.setter(#selfAssets, _selfAssets),
          returnValueForMissingStub: null);
  @override
  set selfComplianceLevel(int? _selfComplianceLevel) => super.noSuchMethod(
      Invocation.setter(#selfComplianceLevel, _selfComplianceLevel),
      returnValueForMissingStub: null);
  @override
  set selfDownloads(_i3.CoreDownloads? _selfDownloads) =>
      super.noSuchMethod(Invocation.setter(#selfDownloads, _selfDownloads),
          returnValueForMissingStub: null);
  @override
  String get selfID =>
      (super.noSuchMethod(Invocation.getter(#selfID), returnValue: '')
          as String);
  @override
  set selfID(String? _selfID) =>
      super.noSuchMethod(Invocation.setter(#selfID, _selfID),
          returnValueForMissingStub: null);
  @override
  set selfInheritsFrom(String? _selfInheritsFrom) => super.noSuchMethod(
      Invocation.setter(#selfInheritsFrom, _selfInheritsFrom),
      returnValueForMissingStub: null);
  @override
  set selfLibraries(List<_i15.Library>? _selfLibraries) =>
      super.noSuchMethod(Invocation.setter(#selfLibraries, _selfLibraries),
          returnValueForMissingStub: null);
  @override
  set selfMainClass(String? _selfMainClass) =>
      super.noSuchMethod(Invocation.setter(#selfMainClass, _selfMainClass),
          returnValueForMissingStub: null);
  @override
  set selfMinecraftArguments(String? _selfMinecraftArguments) =>
      super.noSuchMethod(
          Invocation.setter(#selfMinecraftArguments, _selfMinecraftArguments),
          returnValueForMissingStub: null);
  @override
  set selfReleaseTime(DateTime? _selfReleaseTime) =>
      super.noSuchMethod(Invocation.setter(#selfReleaseTime, _selfReleaseTime),
          returnValueForMissingStub: null);
  @override
  set selfTime(DateTime? _selfTime) =>
      super.noSuchMethod(Invocation.setter(#selfTime, _selfTime),
          returnValueForMissingStub: null);
  @override
  set selfType(_i16.VersionType? _selfType) =>
      super.noSuchMethod(Invocation.setter(#selfType, _selfType),
          returnValueForMissingStub: null);
  @override
  String get assets =>
      (super.noSuchMethod(Invocation.getter(#assets), returnValue: '')
          as String);
  @override
  _i3.CoreDownloads get downloads =>
      (super.noSuchMethod(Invocation.getter(#downloads),
          returnValue: _FakeCoreDownloads()) as _i3.CoreDownloads);
  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  List<_i15.Library> get libraries =>
      (super.noSuchMethod(Invocation.getter(#libraries),
          returnValue: <_i15.Library>[]) as List<_i15.Library>);
  @override
  String get mainClass =>
      (super.noSuchMethod(Invocation.getter(#mainClass), returnValue: '')
          as String);
  @override
  DateTime get releaseTime =>
      (super.noSuchMethod(Invocation.getter(#releaseTime),
          returnValue: _FakeDateTime()) as DateTime);
  @override
  DateTime get time => (super.noSuchMethod(Invocation.getter(#time),
      returnValue: _FakeDateTime()) as DateTime);
  @override
  _i16.VersionType get type => (super.noSuchMethod(Invocation.getter(#type),
      returnValue: _i16.VersionType.snapshot) as _i16.VersionType);
  @override
  Map<String, dynamic> toJson() =>
      (super.noSuchMethod(Invocation.method(#toJson, []),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
}
