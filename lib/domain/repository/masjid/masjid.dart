import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart'; // Import Model Donasi

abstract class MasjidRepository {
  //Future<Either> getNewsMasjids();

  Future<Either> getAllMasjids();
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile});
  
  // Tambahan kontrak untuk fitur Tambah Donasi
  Future<Either> createDonation(String masjidId, DonasiModel donasi, {File? imageFile});
}