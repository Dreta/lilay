// Mocks generated by Mockito 5.0.10 from annotations
// in lilay/test/core/download/version/assets/asset_download_task_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i2;
import 'dart:convert' as _i7;
import 'dart:typed_data' as _i6;

import 'package:http/src/base_request.dart' as _i9;
import 'package:http/src/byte_stream.dart' as _i5;
import 'package:http/src/client.dart' as _i8;
import 'package:http/src/response.dart' as _i3;
import 'package:http/src/streamed_response.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeStreamSubscription<T> extends _i1.Fake
    implements _i2.StreamSubscription<T> {}

class _FakeResponse extends _i1.Fake implements _i3.Response {}

class _FakeStreamedResponse extends _i1.Fake implements _i4.StreamedResponse {}

class _FakeByteStream extends _i1.Fake implements _i5.ByteStream {}

/// A class which mocks [ByteStream].
///
/// See the documentation for Mockito's code generation for more information.
class MockByteStream extends _i1.Mock implements _i5.ByteStream {
  MockByteStream() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isBroadcast =>
      (super.noSuchMethod(Invocation.getter(#isBroadcast), returnValue: false)
          as bool);
  @override
  _i2.Future<int> get length => (super.noSuchMethod(Invocation.getter(#length),
      returnValue: Future<int>.value(0)) as _i2.Future<int>);
  @override
  _i2.Future<bool> get isEmpty =>
      (super.noSuchMethod(Invocation.getter(#isEmpty),
          returnValue: Future<bool>.value(false)) as _i2.Future<bool>);
  @override
  _i2.Future<List<int>> get first => (super.noSuchMethod(
      Invocation.getter(#first),
      returnValue: Future<List<int>>.value(<int>[])) as _i2.Future<List<int>>);
  @override
  _i2.Future<List<int>> get last => (super.noSuchMethod(
      Invocation.getter(#last),
      returnValue: Future<List<int>>.value(<int>[])) as _i2.Future<List<int>>);
  @override
  _i2.Future<List<int>> get single => (super.noSuchMethod(
      Invocation.getter(#single),
      returnValue: Future<List<int>>.value(<int>[])) as _i2.Future<List<int>>);
  @override
  _i2.Future<_i6.Uint8List> toBytes() =>
      (super.noSuchMethod(Invocation.method(#toBytes, []),
              returnValue: Future<_i6.Uint8List>.value(_i6.Uint8List(0)))
          as _i2.Future<_i6.Uint8List>);
  @override
  _i2.Future<String> bytesToString(
          [_i7.Encoding? encoding = const _i7.Utf8Codec()]) =>
      (super.noSuchMethod(Invocation.method(#bytesToString, [encoding]),
          returnValue: Future<String>.value('')) as _i2.Future<String>);
  @override
  _i2.Stream<String> toStringStream(
          [_i7.Encoding? encoding = const _i7.Utf8Codec()]) =>
      (super.noSuchMethod(Invocation.method(#toStringStream, [encoding]),
          returnValue: Stream<String>.empty()) as _i2.Stream<String>);
  @override
  _i2.Stream<List<int>> asBroadcastStream(
          {void Function(_i2.StreamSubscription<List<int>>)? onListen,
          void Function(_i2.StreamSubscription<List<int>>)? onCancel}) =>
      (super.noSuchMethod(
          Invocation.method(#asBroadcastStream, [],
              {#onListen: onListen, #onCancel: onCancel}),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      (super.noSuchMethod(
              Invocation.method(#listen, [
                onData
              ], {
                #onError: onError,
                #onDone: onDone,
                #cancelOnError: cancelOnError
              }),
              returnValue: _FakeStreamSubscription<List<int>>())
          as _i2.StreamSubscription<List<int>>);
  @override
  _i2.Stream<List<int>> where(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#where, [test]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<S> map<S>(S Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#map, [convert]),
          returnValue: Stream<S>.empty()) as _i2.Stream<S>);
  @override
  _i2.Stream<E> asyncMap<E>(_i2.FutureOr<E>? Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#asyncMap, [convert]),
          returnValue: Stream<E>.empty()) as _i2.Stream<E>);
  @override
  _i2.Stream<E> asyncExpand<E>(_i2.Stream<E>? Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#asyncExpand, [convert]),
          returnValue: Stream<E>.empty()) as _i2.Stream<E>);
  @override
  _i2.Stream<List<int>> handleError(Function? onError,
          {bool Function(dynamic)? test}) =>
      (super.noSuchMethod(
          Invocation.method(#handleError, [onError], {#test: test}),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<S> expand<S>(Iterable<S> Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#expand, [convert]),
          returnValue: Stream<S>.empty()) as _i2.Stream<S>);
  @override
  _i2.Future<dynamic> pipe(_i2.StreamConsumer<List<int>>? streamConsumer) =>
      (super.noSuchMethod(Invocation.method(#pipe, [streamConsumer]),
          returnValue: Future<dynamic>.value()) as _i2.Future<dynamic>);
  @override
  _i2.Stream<S> transform<S>(
          _i2.StreamTransformer<List<int>, S>? streamTransformer) =>
      (super.noSuchMethod(Invocation.method(#transform, [streamTransformer]),
          returnValue: Stream<S>.empty()) as _i2.Stream<S>);
  @override
  _i2.Future<List<int>> reduce(
          List<int> Function(List<int>, List<int>)? combine) =>
      (super.noSuchMethod(Invocation.method(#reduce, [combine]),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i2.Future<List<int>>);
  @override
  _i2.Future<S> fold<S>(S? initialValue, S Function(S, List<int>)? combine) =>
      (super.noSuchMethod(Invocation.method(#fold, [initialValue, combine]),
          returnValue: Future<S>.value(null)) as _i2.Future<S>);
  @override
  _i2.Future<String> join([String? separator = r'']) =>
      (super.noSuchMethod(Invocation.method(#join, [separator]),
          returnValue: Future<String>.value('')) as _i2.Future<String>);
  @override
  _i2.Future<bool> contains(Object? needle) =>
      (super.noSuchMethod(Invocation.method(#contains, [needle]),
          returnValue: Future<bool>.value(false)) as _i2.Future<bool>);
  @override
  _i2.Future<dynamic> forEach(void Function(List<int>)? action) =>
      (super.noSuchMethod(Invocation.method(#forEach, [action]),
          returnValue: Future<dynamic>.value()) as _i2.Future<dynamic>);
  @override
  _i2.Future<bool> every(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#every, [test]),
          returnValue: Future<bool>.value(false)) as _i2.Future<bool>);
  @override
  _i2.Future<bool> any(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#any, [test]),
          returnValue: Future<bool>.value(false)) as _i2.Future<bool>);
  @override
  _i2.Stream<R> cast<R>() => (super.noSuchMethod(Invocation.method(#cast, []),
      returnValue: Stream<R>.empty()) as _i2.Stream<R>);
  @override
  _i2.Future<List<List<int>>> toList() =>
      (super.noSuchMethod(Invocation.method(#toList, []),
              returnValue: Future<List<List<int>>>.value(<List<int>>[]))
          as _i2.Future<List<List<int>>>);
  @override
  _i2.Future<Set<List<int>>> toSet() =>
      (super.noSuchMethod(Invocation.method(#toSet, []),
              returnValue: Future<Set<List<int>>>.value(<List<int>>{}))
          as _i2.Future<Set<List<int>>>);
  @override
  _i2.Future<E> drain<E>([E? futureValue]) =>
      (super.noSuchMethod(Invocation.method(#drain, [futureValue]),
          returnValue: Future<E>.value(null)) as _i2.Future<E>);
  @override
  _i2.Stream<List<int>> take(int? count) =>
      (super.noSuchMethod(Invocation.method(#take, [count]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<List<int>> takeWhile(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#takeWhile, [test]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<List<int>> skip(int? count) =>
      (super.noSuchMethod(Invocation.method(#skip, [count]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<List<int>> skipWhile(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#skipWhile, [test]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Stream<List<int>> distinct(
          [bool Function(List<int>, List<int>)? equals]) =>
      (super.noSuchMethod(Invocation.method(#distinct, [equals]),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
  @override
  _i2.Future<List<int>> firstWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#firstWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i2.Future<List<int>>);
  @override
  _i2.Future<List<int>> lastWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#lastWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i2.Future<List<int>>);
  @override
  _i2.Future<List<int>> singleWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#singleWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i2.Future<List<int>>);
  @override
  _i2.Future<List<int>> elementAt(int? index) => (super.noSuchMethod(
      Invocation.method(#elementAt, [index]),
      returnValue: Future<List<int>>.value(<int>[])) as _i2.Future<List<int>>);
  @override
  _i2.Stream<List<int>> timeout(Duration? timeLimit,
          {void Function(_i2.EventSink<List<int>>)? onTimeout}) =>
      (super.noSuchMethod(
          Invocation.method(#timeout, [timeLimit], {#onTimeout: onTimeout}),
          returnValue: Stream<List<int>>.empty()) as _i2.Stream<List<int>>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i8.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Future<_i3.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<_i3.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<_i3.Response> post(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<_i3.Response> put(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<_i3.Response> patch(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<_i3.Response> delete(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse()))
          as _i2.Future<_i3.Response>);
  @override
  _i2.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}),
          returnValue: Future<String>.value('')) as _i2.Future<String>);
  @override
  _i2.Future<_i6.Uint8List> readBytes(Uri? url,
          {Map<String, String>? headers}) =>
      (super.noSuchMethod(
              Invocation.method(#readBytes, [url], {#headers: headers}),
              returnValue: Future<_i6.Uint8List>.value(_i6.Uint8List(0)))
          as _i2.Future<_i6.Uint8List>);
  @override
  _i2.Future<_i4.StreamedResponse> send(_i9.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]),
              returnValue:
                  Future<_i4.StreamedResponse>.value(_FakeStreamedResponse()))
          as _i2.Future<_i4.StreamedResponse>);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
}

/// A class which mocks [StreamedResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamedResponse extends _i1.Mock implements _i4.StreamedResponse {
  MockStreamedResponse() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.ByteStream get stream => (super.noSuchMethod(Invocation.getter(#stream),
      returnValue: _FakeByteStream()) as _i5.ByteStream);
  @override
  int get statusCode =>
      (super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0)
          as int);
  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(Invocation.getter(#headers),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  bool get isRedirect =>
      (super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false)
          as bool);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool);
}

/// A class which mocks [StreamSubscription].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamSubscription<T> extends _i1.Mock
    implements _i2.StreamSubscription<T> {
  MockStreamSubscription() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isPaused =>
      (super.noSuchMethod(Invocation.getter(#isPaused), returnValue: false)
          as bool);
  @override
  _i2.Future<void> cancel() =>
      (super.noSuchMethod(Invocation.method(#cancel, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i2.Future<void>);
  @override
  void onData(void Function(T)? handleData) =>
      super.noSuchMethod(Invocation.method(#onData, [handleData]),
          returnValueForMissingStub: null);
  @override
  void onError(Function? handleError) =>
      super.noSuchMethod(Invocation.method(#onError, [handleError]),
          returnValueForMissingStub: null);
  @override
  void onDone(void Function()? handleDone) =>
      super.noSuchMethod(Invocation.method(#onDone, [handleDone]),
          returnValueForMissingStub: null);
  @override
  void pause([_i2.Future<void>? resumeSignal]) =>
      super.noSuchMethod(Invocation.method(#pause, [resumeSignal]),
          returnValueForMissingStub: null);
  @override
  void resume() => super.noSuchMethod(Invocation.method(#resume, []),
      returnValueForMissingStub: null);
  @override
  _i2.Future<E> asFuture<E>([E? futureValue]) =>
      (super.noSuchMethod(Invocation.method(#asFuture, [futureValue]),
          returnValue: Future<E>.value(null)) as _i2.Future<E>);
}
