import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/chat/domain/entities/chat_analytics_entity.dart';
import 'package:frontend_admin/features/chat/domain/repository/chat_repository.dart';

class GetChatAnalytics
    implements UseCase<ChatAnalyticsEntity, GetChatAnalyticsParams> {
  final ChatRepository repository;

  GetChatAnalytics(this.repository);

  @override
  Future<Either<Failure, ChatAnalyticsEntity>> call(
    GetChatAnalyticsParams params,
  ) async {
    return await repository.getAnalytics(days: params.days);
  }
}

class GetChatAnalyticsParams extends Equatable {
  final int days;

  const GetChatAnalyticsParams({this.days = 30});

  @override
  List<Object?> get props => [days];
}
