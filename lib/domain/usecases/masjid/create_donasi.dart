import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart';
import 'package:sajadah/domain/repository/masjid/masjid.dart';
import 'package:sajadah/service_locator.dart';

class CreateDonasiUseCase {
  Future<Either> call(String masjidId, DonasiModel donasi, {File? imageFile}) async {
    return await sl<MasjidRepository>().createDonation(
      masjidId,
      donasi,
      imageFile: imageFile,
    );
  }
}