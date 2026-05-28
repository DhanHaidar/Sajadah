import 'package:dartz/dartz.dart';
import 'package:sajadah/domain/repository/donasi/donasi.dart';
import 'package:sajadah/service_locator.dart';

class UpdateDonasiCollectedAmountUseCase {
  Future<Either> call({
    required String masjidId,
    required String donasiId,
    required double amount,
  }) async {
    return await sl<DonasiRepository>().updateCollectedAmount(
      masjidId,
      donasiId,
      amount,
    );
  }
}
