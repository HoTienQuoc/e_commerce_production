import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/chat/domain/entities/chat_response_entity.dart';
import 'package:frontend_admin/features/chat/domain/repository/chat_repository.dart';

class SendChatQueryUsecase
    implements UseCase<ChatResponseEntity, SendChatQueryParams> {
  final ChatRepository repository;

  SendChatQueryUsecase(this.repository);

  @override
  Future<Either<Failure, ChatResponseEntity>> call(
    SendChatQueryParams params,
  ) async {
    return await repository.sendQuery(
      params.query,
      sessionId: params.sessionId,
      context: params.context,
    );
  }
}

class SendChatQueryParams {
  final String query;
  final String? sessionId;
  final Map<String, dynamic>? context;

  const SendChatQueryParams({
    required this.query,
    this.sessionId,
    this.context,
  });
}
