import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart';
import 'package:sajadah/domain/repository/donasi/donasi.dart';
import 'package:sajadah/service_locator.dart';

class CreateDonasiUseCase {
  Future<Either> call(
    String masjidId,
    DonasiModel donasi, {
    File? imageFile,
  }) async {
    return await sl<DonasiRepository>().createDonation(
      masjidId,
      donasi,
      imageFile: imageFile,
    );
  }
}
