import 'package:dartz/dartz.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';

abstract class JamaahRepository {
  Future<Either> getJamaahsByMasjid(String masjidId);
  Future<Either> createJamaah(JamaahEntity jamaah);
  Future<Either> createJamaahForMasjid(String masjidId, JamaahEntity jamaah);
}
