import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';

abstract class MasjidRepository {
  //Future<Either> getNewsMasjids();

  Future<Either> getAllMasjids();
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile});
}
