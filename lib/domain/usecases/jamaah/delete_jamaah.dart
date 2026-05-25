import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/service_locator.dart';

class DeleteJamaahUseCase implements UseCase<Either, DeleteJamaahParams> {
  @override
  Future<Either<dynamic, dynamic>> call({DeleteJamaahParams? params}) async {
    if (params == null) return const Left('Params tidak boleh kosong');

    if (params.masjidId != null && params.masjidId!.isNotEmpty) {
      return await sl<JamaahRepository>().deleteJamaahForMasjid(
        params.masjidId!,
        params.docId,
      );
    }

    return await sl<JamaahRepository>().deleteJamaah(params.docId);
  }
}

class DeleteJamaahParams {
  final String docId;
  final String? masjidId;
  DeleteJamaahParams({required this.docId, this.masjidId});
}
