import 'package:omni_preview/features/main/domain/entities/recent_list_entity.dart';

class RecentListModel extends RecentListEntity {
  RecentListModel({required super.recentFiles});

  factory RecentListModel.fromJson(List<dynamic> json) {
    return RecentListModel(recentFiles: json.map((e) => e as String).toList());
  }
}
