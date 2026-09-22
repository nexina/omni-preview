import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_preview/features/main/domain/usecase/recent_list.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_event.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_state.dart';

class RecentListBloc extends Bloc<RecentListEvent, RecentListState> {
  final GetRecentList getRecentFiles;
  final AddFileInRecent addRecentFile;
  final RemoveFileFromRecentList removeRecentFile;
  final ClearRecentList clearRecentFiles;

  RecentListBloc({
    required this.getRecentFiles,
    required this.addRecentFile,
    required this.removeRecentFile,
    required this.clearRecentFiles,
  }) : super(const RecentListInitial()) {
    on<LoadRecentListEvent>(_onLoadRecentList);
    on<AddFileToRecentListEvent>(_onAddFile);
    on<RemoveFileFromRecentListEvent>(_onRemoveFile);
    on<ClearRecentListEvent>(_onClearList);
  }

  Future<void> _onLoadRecentList(
    LoadRecentListEvent event,
    Emitter<RecentListState> emit,
  ) async {
    emit(const RecentListLoading());
    try {
      final files = await getRecentFiles();
      emit(RecentListLoaded(recentFiles: files));
    } catch (e) {
      emit(RecentListError(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddFile(
    AddFileToRecentListEvent event,
    Emitter<RecentListState> emit,
  ) async {
    await addRecentFile(event.workingFile);
    add(LoadRecentListEvent());
  }

  Future<void> _onRemoveFile(
    RemoveFileFromRecentListEvent event,
    Emitter<RecentListState> emit,
  ) async {
    await removeRecentFile(event.workingFile);
    add(LoadRecentListEvent());
  }

  Future<void> _onClearList(
    ClearRecentListEvent event,
    Emitter<RecentListState> emit,
  ) async {
    await clearRecentFiles();
    emit(const RecentListLoaded(recentFiles: []));
  }
}
