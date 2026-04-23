import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/service_locator.dart';

class CreateEventUseCase implements UseCase<Either, CreateEventParams> {
  @override
  Future<Either<dynamic, dynamic>> call({CreateEventParams? params}) async {
    if (params == null) {
      return const Left("Params tidak boleh kosong");
    }
    return await sl<EventRepository>().createEvent(
      params.event,
      imageFile: params.imageFile,
    );
  }
}

class CreateEventParams {
  final EventModel event;
  final File? imageFile;

  CreateEventParams({required this.event, this.imageFile});
}
