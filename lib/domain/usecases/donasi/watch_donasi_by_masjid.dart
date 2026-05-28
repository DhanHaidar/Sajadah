import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';
import 'package:sajadah/domain/repository/donasi/donasi.dart';
import 'package:sajadah/service_locator.dart';

class WatchDonasiByMasjidUseCase {
  Stream<List<DonasiEntity>> call({required String masjidId}) {
    return sl<DonasiRepository>().watchDonasiByMasjid(masjidId);
  }
}
