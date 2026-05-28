import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/donasi/donasi.dart';
import 'package:sajadah/service_locator.dart';

class GetDonasiByMasjidUseCase
    implements UseCase<Either, GetDonasiByMasjidParams> {
  @override
  Future<Either<dynamic, dynamic>> call({
    GetDonasiByMasjidParams? params,
  }) async {
    if (params == null) return const Left('masjidId tidak boleh kosong');
    return await sl<DonasiRepository>().getDonasiByMasjid(params.masjidId);
  }
}

class GetDonasiByMasjidParams {
  final String masjidId;
  GetDonasiByMasjidParams({required this.masjidId});
}
