import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';

abstract class LaporanKegiatanRepository {
  Future<Either> createLaporanKegiatan(
    EventModel laporan, {
    File? imageFile,
    File? documentFile,
    String? documentName,
  });
}
