import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/chat/domain/entities/paginated_session_entity.dart';
import 'package:frontend_admin/features/chat/domain/repository/chat_repository.dart';

class GetChatSessionUsecase
    implements UseCase<PaginatedSessionEntity, GetChatSessionParams> {
  final ChatRepository repository;

  GetChatSessionUsecase(this.repository);

  @override
  Future<Either<Failure, PaginatedSessionEntity>> call(
    GetChatSessionParams params,
  ) async {
    return await repository.getSessions(page: params.page);
  }
}

class GetChatSessionParams extends Equatable {
  final int page;

  const GetChatSessionParams({required this.page});

  @override
  List<Object?> get props => [page];
}
