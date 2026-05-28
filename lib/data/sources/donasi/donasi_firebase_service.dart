import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';

abstract class DonasiFirebaseService {
  Future<Either> getDonasiByMasjid(String masjidId);
  Stream<List<DonasiEntity>> watchDonasiByMasjid(String masjidId);
  Future<Either> createDonation(
    String masjidId,
    DonasiModel donasi, {
    File? imageFile,
  });
  Future<Either> updateCollectedAmount(
    String masjidId,
    String donasiId,
    double amount,
  );
}

class DonasiFirebaseServiceImpl extends DonasiFirebaseService {
  @override
  Future<Either> getDonasiByMasjid(String masjidId) async {
    try {
      List<DonasiEntity> donasis = [];
      var data = await FirebaseFirestore.instance
          .collection('Masjid')
          .doc(masjidId)
          .collection('Donasi')
          .orderBy('createdAt', descending: true)
          .get();

      for (var element in data.docs) {
        final raw = element.data();
        var donasiModel = DonasiModel.fromJson(
          raw,
          docId: element.id,
          masjidId: masjidId,
        );
        donasis.add(donasiModel.toEntity());
      }

      return Right(donasis);
    } catch (e) {
      return Left("Gagal mengambil donasi untuk masjid $masjidId: $e");
    }
  }

  @override
  Stream<List<DonasiEntity>> watchDonasiByMasjid(String masjidId) {
    return FirebaseFirestore.instance
        .collection('Masjid')
        .doc(masjidId)
        .collection('Donasi')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final raw = doc.data();
            final donasiModel = DonasiModel.fromJson(
              raw,
              docId: doc.id,
              masjidId: masjidId,
            );
            return donasiModel.toEntity();
          }).toList();
        });
  }

  @override
  Future<Either> createDonation(
    String masjidId,
    DonasiModel donasi, {
    File? imageFile,
  }) async {
    try {
      String? uploadedImageUrl;

      if (imageFile != null) {
        try {
          final extension = imageFile.path.split('.').last;
          final fileName =
              'donasi_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final path = 'donasi_images/$fileName';

          print('📸 Uploading donasi image to Supabase: $path');
          await Supabase.instance.client.storage
              .from('SajadaApp')
              .upload(path, imageFile);

          uploadedImageUrl = Supabase.instance.client.storage
              .from('SajadaApp')
              .getPublicUrl(path);
          print('✅ Upload donasi image successful: $uploadedImageUrl');
        } catch (storageError) {
          print(
            '⚠️ Supabase Storage error (lanjut tanpa gambar): $storageError',
          );
        }
      }

      final donasiData = donasi.toJson();
      donasiData['createdAt'] = FieldValue.serverTimestamp();
      donasiData['masjidId'] = masjidId;
      if (uploadedImageUrl != null) {
        donasiData['imageUrl'] = uploadedImageUrl;
      }

      print(
        '💾 Saving Donation to Firestore subcollection: Masjid/$masjidId/Donasi',
      );

      final docRef = await FirebaseFirestore.instance
          .collection('Masjid')
          .doc(masjidId)
          .collection('Donasi')
          .add(donasiData);

      print('✅ Firestore Donation save successful: ${docRef.id}');
      return Right(docRef.id);
    } catch (e) {
      print('❌ Error creating donation: $e');
      return Left("Gagal membuat donasi: $e");
    }
  }

  @override
  Future<Either> updateCollectedAmount(
    String masjidId,
    String donasiId,
    double amount,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Masjid')
          .doc(masjidId)
          .collection('Donasi')
          .doc(donasiId)
          .update({
            'collectedAmount': FieldValue.increment(amount),
            'lastDonationAmount': amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return const Right(true);
    } catch (e) {
      return Left('Gagal memperbarui nominal donasi: $e');
    }
  }
}
