import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';

abstract class DonasiRepository {
  Future<Either> getDonasiByMasjid(String masjidId);
  Stream<List<DonasiEntity>> watchDonasiByMasjid(String masjidId);
  Future<Either> createDonation(
    String masjidId,
    DonasiModel donasi, {
    File? imageFile,
  });
  Future<Either> updateCollectedAmount(
    String masjidId,
    String donasiId,
    double amount,
  );
}
