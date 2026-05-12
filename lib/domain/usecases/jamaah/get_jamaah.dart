import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/service_locator.dart';

class GetJamaahsByMasjidUseCase
    implements UseCase<Either, GetJamaahsByMasjidParams> {
  @override
  Future<Either<dynamic, dynamic>> call({
    GetJamaahsByMasjidParams? params,
  }) async {
    if (params == null) return const Left('masjidId tidak boleh kosong');
    return await sl<JamaahRepository>().getJamaahsByMasjid(params.masjidId);
  }
}

class GetJamaahsByMasjidParams {
  final String masjidId;
  GetJamaahsByMasjidParams({required this.masjidId});
}
