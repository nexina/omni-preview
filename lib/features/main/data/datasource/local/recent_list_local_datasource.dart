import 'dart:convert';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RecentListLocalDataSource {
  Future<List<WorkingFile>> getFiles();
  Future<void> saveFiles(List<WorkingFile> files);
  Future<void> clear();
}

class RecentListLocalDataSourceImpl implements RecentListLocalDataSource {
  static const _key = 'recent_files_list';

  final SharedPreferences prefs;

  RecentListLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<WorkingFile>> getFiles() async {
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList
        .map((item) => WorkingFile.fromMap(jsonDecode(item)))
        .toList();
  }

  @override
  Future<void> saveFiles(List<WorkingFile> files) async {
    final List<String> jsonList = files
        .map((file) => jsonEncode(file.toMap()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }

  @override
  Future<void> clear() async {
    await prefs.remove(_key);
  }
}
