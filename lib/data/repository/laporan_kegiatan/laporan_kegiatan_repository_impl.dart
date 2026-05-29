import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/data/sources/laporan_kegiatan/laporan_kegiatan_firebase_service.dart';
import 'package:sajadah/domain/repository/laporan_kegiatan/laporan_kegiatan.dart';
import 'package:sajadah/service_locator.dart';

class LaporanKegiatanRepositoryImpl extends LaporanKegiatanRepository {
  @override
  Future<Either> createLaporanKegiatan(
    EventModel laporan, {
    File? imageFile,
    File? documentFile,
    String? documentName,
  }) async {
    return await sl<LaporanKegiatanFirebaseService>().createLaporanKegiatan(
      laporan,
      imageFile: imageFile,
      documentFile: documentFile,
      documentName: documentName,
    );
  }
}
