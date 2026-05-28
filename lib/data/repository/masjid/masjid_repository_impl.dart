import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/data/sources/masjid/masjid_firebase_service.dart';
import 'package:sajadah/domain/repository/masjid/masjid.dart';
import 'package:sajadah/service_locator.dart';

class MasjidRepositoryImpl extends MasjidRepository {
  // @override
  // Future<Either> getNewsEvents() async {
  //   return await sl<MasjidFirebaseService>().getMasjids();
  // }

  @override
  Future<Either> getAllMasjids() async {
    return await sl<MasjidFirebaseService>().getAllMasjids();
  }

  @override
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile}) async {
    return await sl<MasjidFirebaseService>().createMasjid(
      masjid,
      imageFile: imageFile,
    );
  }
}
