import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/entities/event/event.dart';

class EventModel {
  final String? id;
  final String title;
  final String deskripsi;
  final String? speaker;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;

  EventModel({
    this.id,
    required this.title,
    required this.deskripsi,
    this.speaker,
    required this.dateTime,
    required this.location,
    this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> data, {String? docId}) {
    // Firestore often stores timestamps under custom keys (here: 'waktu').
    final dynamic waktu =
        data['waktu'] ??
        data['dateTime'] ??
        data['date_time'] ??
        data['date'] ??
        data['time'];

    DateTime parsedDate;
    if (waktu == null) {
      parsedDate = DateTime.now();
    } else if (waktu is Timestamp) {
      parsedDate = waktu.toDate();
    } else if (waktu is DateTime) {
      parsedDate = waktu;
    } else if (waktu is String) {
      parsedDate = DateTime.tryParse(waktu) ?? DateTime.now();
    } else if (waktu is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(waktu);
    } else {
      parsedDate = DateTime.now();
    }

    return EventModel(
      id: docId,
      title:
          (data['title'] as String?) ??
          (data['judul'] as String?) ??
          (data['name'] as String?) ??
          (data['nama'] as String?) ??
          '',
      deskripsi:
          (data['deskripsi'] as String?) ??
          (data['description'] as String?) ??
          (data['desc'] as String?) ??
          '',
      speaker: (data['speaker'] as String?),
      dateTime: parsedDate,
      location:
          (data['location'] as String?) ?? (data['lokasi'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? (data['image'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deskripsi': deskripsi,
      'speaker': speaker,
      'waktu': Timestamp.fromDate(dateTime),
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}

extension EventModelX on EventModel {
  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      deskripsi: deskripsi,
      speaker: speaker,
      dateTime: dateTime,
      location: location,
      imageUrl: imageUrl,
    );
  }
}
