import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/repository/laporan_kegiatan/laporan_kegiatan.dart';
import 'package:sajadah/service_locator.dart';

class CreateLaporanKegiatanUseCase
    implements UseCase<Either, CreateLaporanKegiatanParams> {
  @override
  Future<Either<dynamic, dynamic>> call({
    CreateLaporanKegiatanParams? params,
  }) async {
    if (params == null) {
      return const Left('Params tidak boleh kosong');
    }

    return await sl<LaporanKegiatanRepository>().createLaporanKegiatan(
      params.laporan,
      imageFile: params.imageFile,
      documentFile: params.documentFile,
      documentName: params.documentName,
    );
  }
}

class CreateLaporanKegiatanParams {
  final EventModel laporan;
  final File? imageFile;
  final File? documentFile;
  final String? documentName;

  CreateLaporanKegiatanParams({
    required this.laporan,
    this.imageFile,
    this.documentFile,
    this.documentName,
  });
}
