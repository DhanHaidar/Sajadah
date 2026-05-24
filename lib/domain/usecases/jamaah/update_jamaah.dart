import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/service_locator.dart';

class UpdateJamaahUseCase implements UseCase<Either, UpdateJamaahParams> {
  @override
  Future<Either<dynamic, dynamic>> call({UpdateJamaahParams? params}) async {
    if (params == null) return const Left('Params tidak boleh kosong');

    final jamaah = params.jamaah;
    if (jamaah.masjidId != null && jamaah.masjidId!.isNotEmpty) {
      return await sl<JamaahRepository>().updateJamaahForMasjid(
        jamaah.masjidId!,
        params.docId,
        jamaah,
      );
    }

    return await sl<JamaahRepository>().updateJamaah(params.docId, jamaah);
  }
}

class UpdateJamaahParams {
  final String docId;
  final JamaahEntity jamaah;
  UpdateJamaahParams({required this.docId, required this.jamaah});
}
