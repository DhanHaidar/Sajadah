import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/domain/repository/masjid/masjid.dart';
import 'package:sajadah/service_locator.dart';

class CreateMasjidUseCase implements UseCase<Either, CreateMasjidParams> {
  @override
  Future<Either<dynamic, dynamic>> call({CreateMasjidParams? params}) async {
    if (params == null) {
      return const Left("Params tidak boleh kosong");
    }
    return await sl<MasjidRepository>().createMasjid(
      params.masjid,
      imageFile: params.imageFile,
    );
  }
}

class CreateMasjidParams {
  final MasjidModel masjid;
  final File? imageFile;

  CreateMasjidParams({required this.masjid, this.imageFile});
}
