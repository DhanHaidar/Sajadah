import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/entities/event/event.dart';

abstract class EventFirebaseService {
  //Future<Either> getEvents();
  Future<Either> getAllEvents();
}

class EventFirebaseServiceImpl extends EventFirebaseService {
  @override
  // Future<Either> getEvents() async {
  //   try {
  //     List<EventEntity> events = [];
  //     var data = await FirebaseFirestore.instance
  //         .collection("Kegiatan")
  //         .orderBy('waktu', descending: true)
  //         .get();
  //     for (var element in data.docs) {
  //       final raw = element.data();
  //       print('EventFirebaseServiceImpl: doc=${element.id} raw=$raw');
  //       var eventModel = EventModel.fromJson(raw);
  //       print(
  //         'EventFirebaseServiceImpl: mapped title="${eventModel.title}", deskripsi="${eventModel.deskripsi}"',
  //       );
  //       events.add(eventModel.toEntity());
  //     }
  //     return Right(events);
  //   } catch (e) {
  //     return const Left("An error occurred while fetching events");
  //   }
  // }

  @override
  Future<Either> getAllEvents() async {
    try {
      List<EventEntity> events = [];
      var data = await FirebaseFirestore.instance
          .collection("Kegiatan")
          .orderBy('waktu', descending: true) // Event terbaru duluan
          .get();

      for (var element in data.docs) {
        final raw = element.data();
        var eventModel = EventModel.fromJson(raw);
        events.add(eventModel.toEntity());
      }

      return Right(events); // Return semua events
    } catch (e) {
      return Left("Gagal mengambil events: $e");
    }
  }
}
