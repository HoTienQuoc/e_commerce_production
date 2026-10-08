import 'package:frontend_admin/features/chat/data/models/chat_session_model.dart';
import 'package:frontend_admin/features/chat/domain/entities/paginated_session_entity.dart';

class PaginatedSessionModel extends PaginatedSessionEntity {
  const PaginatedSessionModel({
    required super.sessions,
    required super.totalCount,
    required super.hasNext,
  });

  factory PaginatedSessionModel.fromJson(Map<String, dynamic> json) {
    final results =
        (json['results'] as List<dynamic>?)
            ?.map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PaginatedSessionModel(
      sessions: results,
      totalCount: json['count'] as int? ?? 0,
      hasNext: json['next'] != null,
    );
  }
}
