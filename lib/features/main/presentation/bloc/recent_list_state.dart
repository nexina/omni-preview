import 'dart:convert';

class RecentListState {
  const RecentListState();
}

class RecentListInitial extends RecentListState {
  const RecentListInitial();
}

class RecentListLoading extends RecentListState {
  const RecentListLoading();
}

class RecentListLoaded extends RecentListState {
  final List<RecentFileItem> recentFiles;
  const RecentListLoaded({required this.recentFiles});
}

class RecentListError extends RecentListState {
  final String errorMessage;
  const RecentListError({required this.errorMessage});
}

class RecentFileItem {
  final String filePath;
  final String fileWorkingPath;
  final String fileSize;
  final DateTime lastOpened;

  RecentFileItem({
    required this.filePath,
    required this.fileWorkingPath,
    required this.lastOpened,
    required this.fileSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'lastOpened': lastOpened.millisecondsSinceEpoch,
      'fileSize': fileSize,
    };
  }

  factory RecentFileItem.fromMap(Map<String, dynamic> map) {
    return RecentFileItem(
      filePath: map['filePath'] ?? '',
      fileWorkingPath: map['fileWorkingPath'] ?? '',
      lastOpened: DateTime.fromMillisecondsSinceEpoch(map['lastOpened'] ?? 0),
      fileSize: map['fileSize'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RecentFileItem.fromJson(String source) =>
      RecentFileItem.fromMap(json.decode(source));
}
