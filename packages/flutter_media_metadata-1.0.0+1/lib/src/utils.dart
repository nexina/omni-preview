/// This file is a part of flutter_media_metadata (https://github.com/alexmercerind/flutter_media_metadata).
///
/// Copyright (c) 2021-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

/// Safely parses [int] from a [String].
int? parseInteger(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is String) {
    // First, try to parse the whole string.
    var result = int.tryParse(value);
    if (result != null) {
      return result;
    }
    // If that fails, it might be in "1/10" format for track numbers.
    final parts = value.split('/');
    return int.tryParse(parts.first);
  }
  return null;
}
