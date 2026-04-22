import 'package:dartz/dartz.dart';
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
}
