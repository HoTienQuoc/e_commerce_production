import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/chat/domain/entities/chat_session_entity.dart';
import 'package:frontend_admin/features/chat/domain/repository/chat_repository.dart';

class CreatedChatSessionUsecase
    implements UseCase<ChatSessionEntity, CreatedChatSessionParams> {
  final ChatRepository repository;

  CreatedChatSessionUsecase(this.repository);

  @override
  Future<Either<Failure, ChatSessionEntity>> call(
    CreatedChatSessionParams params,
  ) async {
    return await repository.createSession(context: params.context);
  }
}

class CreatedChatSessionParams extends Equatable {
  final Map<String, dynamic>? context;

  const CreatedChatSessionParams({this.context});

  @override
  List<Object?> get props => [context];
}
