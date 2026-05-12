import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/masjid/masjid.dart';
import 'package:sajadah/service_locator.dart';

class GetNewsMasjidsUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either<dynamic, dynamic>> call({params}) async {
    return await sl<MasjidRepository>().getAllMasjids();
  }
}
