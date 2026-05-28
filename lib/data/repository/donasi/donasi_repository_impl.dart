import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart';
import 'package:sajadah/data/sources/donasi/donasi_firebase_service.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';
import 'package:sajadah/domain/repository/donasi/donasi.dart';
import 'package:sajadah/service_locator.dart';

class DonasiRepositoryImpl extends DonasiRepository {
  @override
  Future<Either> getDonasiByMasjid(String masjidId) async {
    return await sl<DonasiFirebaseService>().getDonasiByMasjid(masjidId);
  }

  @override
  Stream<List<DonasiEntity>> watchDonasiByMasjid(String masjidId) {
    return sl<DonasiFirebaseService>().watchDonasiByMasjid(masjidId);
  }

  @override
  Future<Either> createDonation(
    String masjidId,
    DonasiModel donasi, {
    File? imageFile,
  }) async {
    return await sl<DonasiFirebaseService>().createDonation(
      masjidId,
      donasi,
      imageFile: imageFile,
    );
  }

  @override
  Future<Either> updateCollectedAmount(
    String masjidId,
    String donasiId,
    double amount,
  ) async {
    return await sl<DonasiFirebaseService>().updateCollectedAmount(
      masjidId,
      donasiId,
      amount,
    );
  }
}
