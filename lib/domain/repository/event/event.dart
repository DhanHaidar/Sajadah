import 'package:dartz/dartz.dart';

abstract class EventRepository {
  //Future<Either> getNewsEvents();
  
  Future<Either> getAllEvents();
}
