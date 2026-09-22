import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_state.dart';

abstract class RecentListRepository {
  Future<List<RecentFileItem>> getRecentFilesWithMeta();
  Future<void> addRecentFile(WorkingFile workingnFile);
  Future<void> removeRecentFile(WorkingFile workingnFile);
  Future<void> clearRecentFiles();
}
