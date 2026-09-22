import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/features/main/domain/repositories/recent_list_repository.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_state.dart';

class GetRecentList {
  final RecentListRepository repository;

  GetRecentList(this.repository);

  Future<List<RecentFileItem>> call() {
    return repository.getRecentFilesWithMeta();
  }
}

class AddFileInRecent {
  final RecentListRepository repository;

  AddFileInRecent(this.repository);

  Future<void> call(WorkingFile workingnFile) {
    return repository.addRecentFile(workingnFile);
  }
}

class RemoveFileFromRecentList {
  final RecentListRepository repository;

  RemoveFileFromRecentList(this.repository);

  Future<void> call(WorkingFile workingFile) {
    return repository.removeRecentFile(workingFile);
  }
}

class ClearRecentList {
  final RecentListRepository repository;

  ClearRecentList(this.repository);

  Future<void> call() {
    return repository.clearRecentFiles();
  }
}
