import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';

abstract class EventRepository {
  //Future<Either> getNewsEvents();

  Future<Either> getAllEvents();
  Future<Either> createEvent(EventModel event, {File? imageFile});
}
