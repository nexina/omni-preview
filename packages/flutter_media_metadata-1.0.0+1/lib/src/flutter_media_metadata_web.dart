/// This file is a part of flutter_media_metadata (https://github.com/alexmercerind/flutter_media_metadata).
///
/// Copyright (c) 2021-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

// ignore_for_file: missing_js_lib_annotation

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:flutter_media_metadata/src/models/metadata.dart';

/// ## MetadataRetriever
///
/// Use [MetadataRetriever.fromBytes] to extract [Metadata] from bytes of media file.
///
/// ```dart
/// final metadata = MetadataRetriever.fromBytes(byteData);
/// String? trackName = metadata.trackName;
/// List<String>? trackArtistNames = metadata.trackArtistNames;
/// String? albumName = metadata.albumName;
/// String? albumArtistName = metadata.albumArtistName;
/// int? trackNumber = metadata.trackNumber;
/// int? albumLength = metadata.albumLength;
/// int? year = metadata.year;
/// String? genre = metadata.genre;
/// String? authorName = metadata.authorName;
/// String? writerName = metadata.writerName;
/// int? discNumber = metadata.discNumber;
/// String? mimeType = metadata.mimeType;
/// int? trackDuration = metadata.trackDuration;
/// int? bitrate = metadata.bitrate;
/// Uint8List? albumArt = metadata.albumArt;
/// ```
///
class MetadataRetriever {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'flutter_media_metadata',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = MetadataRetriever();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) => throw PlatformException(
    code: 'Unimplemented',
    details:
        'flutter_media_metadata for web doesn\'t implement \'${call.method}\'',
  );

  /// Extracts [Metadata] from a [File]. Works on Windows, Linux, macOS, Android & iOS.
  static Future<Metadata> fromFile(dynamic _) async {
    throw UnimplementedError(
      '[MetadataRetriever.fromFile] is not supported on web. This method is only available for Windows, Linux, macOS, Android or iOS. Use [MetadataRetriever.fromBytes] instead.',
    );
  }

  /// Extracts [Metadata] from [Uint8List]. Works only on Web.
  static Future<Metadata> fromBytes(Uint8List bytes) {
    final completer = Completer<Metadata>();
    MediaInfo(
      _Opts(chunkSize: 256 * 1024, coverData: true, format: 'JSON'),
      ((JSObject mediainfoObj) {
        final mediainfo = mediainfoObj as _MediaInfo;
        mediainfo
            .analyzeData(
              (() => bytes.length.toJS).toJS,
              ((JSNumber chunkSize, JSNumber offset) => Future.value(
                      bytes.sublist(
                          offset.toDartInt, offset.toDartInt + chunkSize.toDartInt).toJS)
                  .toJS).toJS,
            )
            .toDart
            .then(
              (result) {
                var rawMetadataJson = jsonDecode(result.toDart)['media']['track'];
                bool isFound = false;
                for (final data in rawMetadataJson) {
                  if (data['@type'] == 'General') {
                    isFound = true;
                    rawMetadataJson = data;
                    break;
                  }
                }
                if (!isFound) {
                  throw Exception();
                }
                final metadata = <String, dynamic>{
                  'metadata': {},
                  'albumArt': base64Decode(rawMetadataJson['Cover_Data']),
                  'filePath': null,
                };
                _kMetadataKeys.forEach((key, value) {
                  metadata['metadata'][key] = rawMetadataJson[value];
                });
                completer.complete(Metadata.fromJson(metadata));
              },
              onError: (error) {
                completer.completeError(Exception(error));
              },
            );
      }).toJS,
      (() {
        completer.completeError(Exception());
      }).toJS,
    );
    return completer.future;
  }
}

@JS('MediaInfo')
external void MediaInfo(
  _Opts opts,
  JSFunction successCallback,
  JSFunction erroCallback,
);

@JS()
@anonymous
extension type _Opts._(JSObject _) implements JSObject {
  external factory _Opts({int chunkSize, bool coverData, String format});
}

@JS()
extension type _MediaInfo._(JSObject _) implements JSObject {
  external JSPromise<JSString> analyzeData(
    JSFunction getSize,
    JSFunction promise,
  );
}

const _kMetadataKeys = <String, String>{
  "trackName": "Track",
  "trackArtistNames": "Performer",
  "albumName": "Album",
  "albumArtistName": "Album_Performer",
  "trackNumber": "Track_Position",
  "albumLength": "Track_Position_Total",
  "year": "Recorded_Date",
  "genre": "Genre",
  "writerName": "WrittenBy",
  "trackDuration": "Duration",
  "bitrate": "OverallBitRate",
};
