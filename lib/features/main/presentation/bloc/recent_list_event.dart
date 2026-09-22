import 'package:omni_preview/core/class/working_file.dart';

class RecentListEvent {
  RecentListEvent();
}

class LoadRecentListEvent extends RecentListEvent {
  LoadRecentListEvent();
}

class AddFileToRecentListEvent extends RecentListEvent {
  final WorkingFile workingFile;
  AddFileToRecentListEvent({required this.workingFile});
}

class RemoveFileFromRecentListEvent extends RecentListEvent {
  final WorkingFile workingFile;
  RemoveFileFromRecentListEvent({required this.workingFile});
}

class ClearRecentListEvent extends RecentListEvent {
  ClearRecentListEvent();
}
