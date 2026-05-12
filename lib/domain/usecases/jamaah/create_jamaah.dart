import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/service_locator.dart';

class CreateJamaahUseCase implements UseCase<Either, CreateJamaahParams> {
  @override
  Future<Either<dynamic, dynamic>> call({CreateJamaahParams? params}) async {
    if (params == null) return const Left('Params tidak boleh kosong');
    // Jika jamaah punya masjidId, simpan ke subcollection Masjid/{masjidId}/Jamaah
    if (params.jamaah.masjidId != null && params.jamaah.masjidId!.isNotEmpty) {
      return await sl<JamaahRepository>().createJamaahForMasjid(
        params.jamaah.masjidId!,
        params.jamaah,
      );
    }

    return await sl<JamaahRepository>().createJamaah(params.jamaah);
  }
}

class CreateJamaahParams {
  final JamaahEntity jamaah;
  CreateJamaahParams({required this.jamaah});
}
