import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/data/sources/event/event_firebase_service.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/service_locator.dart';

class EventRepositoryImpl extends EventRepository {
  // @override
  // Future<Either> getNewsEvents() async {
  //   return await sl<EventFirebaseService>().getEvents();
  // }

  @override
  Future<Either> getAllEvents() async {
    return await sl<EventFirebaseService>().getAllEvents();
  }

  @override
  Future<Either> getEventsByMasjid(String masjidId) async {
    return await sl<EventFirebaseService>().getEventsByMasjid(masjidId);
  }

  @override
  Future<Either> createEvent(EventModel event, {File? imageFile}) async {
    return await sl<EventFirebaseService>().createEvent(
      event,
      imageFile: imageFile,
    );
  }

  @override
  Future<Either> createEventForMasjid(
    String masjidId,
    EventModel event, {
    File? imageFile,
  }) async {
    return await sl<EventFirebaseService>().createEventForMasjid(
      masjidId,
      event,
      imageFile: imageFile,
    );
  }
}
