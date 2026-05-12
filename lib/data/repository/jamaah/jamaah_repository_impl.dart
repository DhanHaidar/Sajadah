import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Jamaah/Jamaah.dart';
import 'package:sajadah/data/sources/jamaah/jamaah_firebase_service.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/service_locator.dart';

class JamaahRepositoryImpl extends JamaahRepository {
  // @override
  // Future<Either> getNewsJamaahs() async {
  //   return await sl<JamaahFirebaseService>().getJamaahs();
  // }

  // @override
  // Future<Either> getAllJamaahs() async {
  //   return await sl<JamaahFirebaseService>().getAllJamaahs();
  // }

  @override
  Future<Either> getJamaahsByMasjid(String masjidId) async {
    return await sl<JamaahFirebaseService>().getJamaahsByMasjid(masjidId);
  }

  @override
  Future<Either> createJamaah(JamaahEntity jamaah) async {
    final jamaahModel = JamaahModel(
      userId: jamaah.userId,
      masjidId: jamaah.masjidId,
      name: jamaah.name,
      jenisKelamin: jamaah.jenisKelamin,
      noHp: jamaah.noHp,
      kategori: jamaah.kategori,
    );

    // Jika jamaah memiliki masjidId, simpan ke subcollection Masjid/{masjidId}/Jamaah
    if (jamaah.masjidId != null && jamaah.masjidId!.isNotEmpty) {
      return await sl<JamaahFirebaseService>().createJamaahForMasjid(
        jamaah.masjidId!,
        jamaahModel,
      );
    }

    return await sl<JamaahFirebaseService>().createJamaah(jamaahModel);
  }

  @override
  Future<Either> createJamaahForMasjid(
    String masjidId,
    JamaahEntity jamaah,
  ) async {
    final jamaahModel = JamaahModel(
      userId: jamaah.userId,
      masjidId: jamaah.masjidId,
      name: jamaah.name,
      jenisKelamin: jamaah.jenisKelamin,
      noHp: jamaah.noHp,
      kategori: jamaah.kategori,
    );

    return await sl<JamaahFirebaseService>().createJamaahForMasjid(
      masjidId,
      jamaahModel,
    );
  }
}
