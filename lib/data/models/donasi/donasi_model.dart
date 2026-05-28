import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';

class DonasiModel {
  final String? id;
  final String? masjidId;
  final String title;
  final String description;
  final double targetAmount;
  final double collectedAmount;
  final DateTime endDate;
  final String? imageUrl;

  DonasiModel({
    this.id,
    this.masjidId,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.collectedAmount = 0.0,
    required this.endDate,
    this.imageUrl,
  });

  factory DonasiModel.fromJson(
    Map<String, dynamic> data, {
    String? docId,
    String? masjidId,
  }) {
    final dynamic rawEndDate =
        data['endDate'] ?? data['end_date'] ?? data['deadline'];

    DateTime parsedEndDate;
    if (rawEndDate == null) {
      parsedEndDate = DateTime.now();
    } else if (rawEndDate is Timestamp) {
      parsedEndDate = rawEndDate.toDate();
    } else if (rawEndDate is DateTime) {
      parsedEndDate = rawEndDate;
    } else if (rawEndDate is String) {
      parsedEndDate = DateTime.tryParse(rawEndDate) ?? DateTime.now();
    } else if (rawEndDate is int) {
      parsedEndDate = DateTime.fromMillisecondsSinceEpoch(rawEndDate);
    } else {
      parsedEndDate = DateTime.now();
    }

    return DonasiModel(
      id: docId,
      masjidId: masjidId ?? (data['masjidId'] as String?),
      title:
          (data['title'] as String?) ??
          (data['judul'] as String?) ??
          (data['name'] as String?) ??
          '',
      description:
          (data['description'] as String?) ??
          (data['deskripsi'] as String?) ??
          (data['desc'] as String?) ??
          '',
      targetAmount: _parseDouble(data['targetAmount']),
      collectedAmount: _parseDouble(data['collectedAmount']),
      endDate: parsedEndDate,
      imageUrl: (data['imageUrl'] as String?) ?? (data['image'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'collectedAmount': collectedAmount,
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
      if (masjidId != null) 'masjidId': masjidId,
    };
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}

extension DonasiModelX on DonasiModel {
  DonasiEntity toEntity() {
    return DonasiEntity(
      id: id,
      masjidId: masjidId,
      title: title,
      description: description,
      targetAmount: targetAmount,
      collectedAmount: collectedAmount,
      endDate: endDate,
      imageUrl: imageUrl,
    );
  }
}
