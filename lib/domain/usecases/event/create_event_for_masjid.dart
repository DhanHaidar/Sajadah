import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/service_locator.dart';

class CreateEventForMasjidUseCase
    implements UseCase<Either, CreateEventForMasjidParams> {
  @override
  Future<Either<dynamic, dynamic>> call({
    CreateEventForMasjidParams? params,
  }) async {
    if (params == null) return const Left('Params tidak boleh kosong');
    return await sl<EventRepository>().createEventForMasjid(
      params.masjidId,
      params.event,
      imageFile: params.imageFile,
    );
  }
}

class CreateEventForMasjidParams {
  final String masjidId;
  final EventModel event;
  final File? imageFile;

  CreateEventForMasjidParams({
    required this.masjidId,
    required this.event,
    this.imageFile,
  });
}
