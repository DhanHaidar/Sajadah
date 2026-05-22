import 'package:dartz/dartz.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';

abstract class JamaahRepository {
  Future<Either> getJamaahsByMasjid(String masjidId);
  Future<Either> createJamaah(JamaahEntity jamaah);
  Future<Either> createJamaahForMasjid(String masjidId, JamaahEntity jamaah);
  Future<Either> updateJamaah(String docId, JamaahEntity jamaah);
  Future<Either> updateJamaahForMasjid(
    String masjidId,
    String docId,
    JamaahEntity jamaah,
  );
  Future<Either> deleteJamaah(String docId);
  Future<Either> deleteJamaahForMasjid(String masjidId, String docId);
}
