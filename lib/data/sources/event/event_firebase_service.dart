import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/entities/event/event.dart';

abstract class EventFirebaseService {
  //Future<Either> getEvents();
  Future<Either> getAllEvents();
  Future<Either> createEvent(EventModel event, {File? imageFile});
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
        var eventModel = EventModel.fromJson(raw, docId: element.id);
        events.add(eventModel.toEntity());
      }

      return Right(events); // Return semua events
    } catch (e) {
      return Left("Gagal mengambil events: $e");
    }
  }

  @override
  Future<Either> createEvent(EventModel event, {File? imageFile}) async {
    try {
      String? uploadedImageUrl;

      // Upload image ke Supabase Storage jika ada
      if (imageFile != null) {
        try {
          final extension = imageFile.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}.$extension';
          final path = 'event_images/$fileName';

          print('📸 Uploading image to Supabase: $path');

          // Upload file ke Supabase bucket 'SajadaApp'
          await Supabase.instance.client.storage
              .from('SajadaApp')
              .upload(path, imageFile);

          print('✅ Upload successful');

          // Get public URL
          uploadedImageUrl = Supabase.instance.client.storage
              .from('SajadaApp')
              .getPublicUrl(path);
          print('📥 Download URL: $uploadedImageUrl');
        } catch (storageError) {
          // Jika upload gambar gagal, lanjut tanpa gambar tapi catat error
          print(
            '⚠️ Supabase Storage error (akan lanjut tanpa gambar): $storageError',
          );
          // Tidak return error, lanjut ke step selanjutnya
        }
      }

      // Buat event baru dengan URL gambar (jika ada)
      final eventData = event.toJson();
      if (uploadedImageUrl != null) {
        eventData['imageUrl'] = uploadedImageUrl;
      }

      print('💾 Saving to Firestore: ${event.title}');

      // Simpan ke Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('Kegiatan')
          .add(eventData);

      print('✅ Firestore save successful: ${docRef.id}');

      return Right(docRef.id);
    } catch (e) {
      print('❌ Error creating event: $e');
      return Left("Gagal membuat event: $e");
    }
  }
}
