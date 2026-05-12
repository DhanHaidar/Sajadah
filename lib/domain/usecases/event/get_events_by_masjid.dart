import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/service_locator.dart';

class GetEventsByMasjidUseCase
    implements UseCase<Either, GetEventsByMasjidParams> {
  @override
  Future<Either<dynamic, dynamic>> call({
    GetEventsByMasjidParams? params,
  }) async {
    if (params == null) return const Left('masjidId tidak boleh kosong');
    return await sl<EventRepository>().getEventsByMasjid(params.masjidId);
  }
}

class GetEventsByMasjidParams {
  final String masjidId;
  GetEventsByMasjidParams({required this.masjidId});
}
