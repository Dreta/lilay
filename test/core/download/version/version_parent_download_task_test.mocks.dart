// Mocks generated by Mockito 5.0.10 from annotations
// in lilay/test/core/download/version/version_parent_download_task_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;
import 'dart:convert' as _i7;
import 'dart:typed_data' as _i8;

import 'package:http/src/base_request.dart' as _i9;
import 'package:http/src/client.dart' as _i5;
import 'package:http/src/response.dart' as _i2;
import 'package:http/src/streamed_response.dart' as _i3;
import 'package:lilay/core/download/task.dart' as _i11;
import 'package:lilay/core/download/version/version_data.dart' as _i12;
import 'package:lilay/core/download/version/version_download_task.dart' as _i10;
import 'package:lilay/core/download/versions/version_info.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeResponse extends _i1.Fake implements _i2.Response {}

class _FakeStreamedResponse extends _i1.Fake implements _i3.StreamedResponse {}

class _FakeVersionInfo extends _i1.Fake implements _i4.VersionInfo {}

class _FakeClient extends _i1.Fake implements _i5.Client {}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i5.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> post(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> put(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> patch(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> delete(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}),
          returnValue: Future<String>.value('')) as _i6.Future<String>);
  @override
  _i6.Future<_i8.Uint8List> readBytes(Uri? url,
          {Map<String, String>? headers}) =>
      (super.noSuchMethod(
              Invocation.method(#readBytes, [url], {#headers: headers}),
              returnValue: Future<_i8.Uint8List>.value(_i8.Uint8List(0)))
          as _i6.Future<_i8.Uint8List>);
  @override
  _i6.Future<_i3.StreamedResponse> send(_i9.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]),
              returnValue:
                  Future<_i3.StreamedResponse>.value(_FakeStreamedResponse()))
          as _i6.Future<_i3.StreamedResponse>);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
}

/// A class which mocks [VersionDownloadTask].
///
/// See the documentation for Mockito's code generation for more information.
class MockVersionDownloadTask extends _i1.Mock
    implements _i10.VersionDownloadTask {
  MockVersionDownloadTask() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<bool> get tryLoadCache =>
      (super.noSuchMethod(Invocation.getter(#tryLoadCache),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  String get source =>
      (super.noSuchMethod(Invocation.getter(#source), returnValue: '')
          as String);
  @override
  bool get cancelled =>
      (super.noSuchMethod(Invocation.getter(#cancelled), returnValue: false)
          as bool);
  @override
  set cancelled(bool? _cancelled) =>
      super.noSuchMethod(Invocation.setter(#cancelled, _cancelled),
          returnValueForMissingStub: null);
  @override
  double get progress =>
      (super.noSuchMethod(Invocation.getter(#progress), returnValue: 0.0)
          as double);
  @override
  set progress(double? _progress) =>
      super.noSuchMethod(Invocation.setter(#progress, _progress),
          returnValueForMissingStub: null);
  @override
  set exception(Object? _exception) =>
      super.noSuchMethod(Invocation.setter(#exception, _exception),
          returnValueForMissingStub: null);
  @override
  set exceptionPhase(_i11.Phase? _exceptionPhase) =>
      super.noSuchMethod(Invocation.setter(#exceptionPhase, _exceptionPhase),
          returnValueForMissingStub: null);
  @override
  _i4.VersionInfo get dependency =>
      (super.noSuchMethod(Invocation.getter(#dependency),
          returnValue: _FakeVersionInfo()) as _i4.VersionInfo);
  @override
  set dependency(_i4.VersionInfo? _dependency) =>
      super.noSuchMethod(Invocation.setter(#dependency, _dependency),
          returnValueForMissingStub: null);
  @override
  set result(_i12.VersionData? _result) =>
      super.noSuchMethod(Invocation.setter(#result, _result),
          returnValueForMissingStub: null);
  @override
  _i5.Client get client => (super.noSuchMethod(Invocation.getter(#client),
      returnValue: _FakeClient()) as _i5.Client);
  @override
  set client(_i5.Client? _client) =>
      super.noSuchMethod(Invocation.setter(#client, _client),
          returnValueForMissingStub: null);
  @override
  String get workingDir =>
      (super.noSuchMethod(Invocation.getter(#workingDir), returnValue: '')
          as String);
  @override
  set workingDir(String? _workingDir) =>
      super.noSuchMethod(Invocation.setter(#workingDir, _workingDir),
          returnValueForMissingStub: null);
  @override
  List<_i11.TaskUpdateCallback> get callbacks =>
      (super.noSuchMethod(Invocation.getter(#callbacks),
              returnValue: <_i11.TaskUpdateCallback>[])
          as List<_i11.TaskUpdateCallback>);
  @override
  bool get finished =>
      (super.noSuchMethod(Invocation.getter(#finished), returnValue: false)
          as bool);
  @override
  _i6.Future<void> download() =>
      (super.noSuchMethod(Invocation.method(#download, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> save() => (super.noSuchMethod(Invocation.method(#save, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future.value()) as _i6.Future<void>);
  @override
  void notify() => super.noSuchMethod(Invocation.method(#notify, []),
      returnValueForMissingStub: null);
  @override
  _i6.Future<void> init() => (super.noSuchMethod(Invocation.method(#init, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> start() => (super.noSuchMethod(Invocation.method(#start, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future.value()) as _i6.Future<void>);
}
