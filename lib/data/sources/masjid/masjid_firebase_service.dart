import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';

abstract class MasjidFirebaseService {
  //Future<Either> getMasjids();
  Future<Either> getAllMasjids();
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile});
}

class MasjidFirebaseServiceImpl extends MasjidFirebaseService {
  @override
  // Future<Either> getMasjids() async {
  //   try {
  //     List<MasjidEntity> masjids = [];
  //     var data = await FirebaseFirestore.instance
  //         .collection("Masjid")
  //         .orderBy('waktu', descending: true)
  //         .get();
  //     for (var element in data.docs) {
  //       final raw = element.data();
  //       print('masjidFirebaseServiceImpl: doc=${element.id} raw=$raw');
  //       var masjidModel = MasjidModel.fromJson(raw);
  //       print(
  //         'masjidFirebaseServiceImpl: mapped title="${masjidModel.title}", deskripsi="${masjidModel.deskripsi}"',
  //       );
  //       masjids.add(masjidModel.toEntity());
  //     }
  //     return Right(masjids);
  //   } catch (e) {
  //     return const Left("An error occurred while fetching masjids");
  //   }
  // }
  @override
  Future<Either> getAllMasjids() async {
    try {
      List<MasjidEntity> masjids = [];

      var data = await FirebaseFirestore.instance
          .collection("Masjid")
          .orderBy('createdAt', descending: true) // Masjid terbaru duluan
          .get();

      for (var element in data.docs) {
        final raw = element.data();
        //print('masjidFirebaseServiceImpl: doc=${element.id} raw=$raw');
        var masjidModel = MasjidModel.fromJson(raw, docId: element.id);
        masjids.add(masjidModel.toEntity());
      }

      return Right(masjids); // Return semua masjids
    } catch (e) {
      return Left("Gagal mengambil masjids: $e");
    }
  }

  @override
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile}) async {
    try {
      String? uploadedImageUrl;

      // Upload image ke Supabase Storage jika ada
      if (imageFile != null) {
        try {
          final extension = imageFile.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}.$extension';
          final path = 'masjid_images/$fileName';

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

      // Buat masjid baru dengan URL gambar (jika ada)
      final masjidData = masjid.toJson();
      // Pastikan ada createdAt agar query orderBy('createdAt') tidak gagal
      masjidData['createdAt'] = FieldValue.serverTimestamp();
      if (uploadedImageUrl != null) {
        masjidData['imageUrl'] = uploadedImageUrl;
      }

      print('💾 Saving to Firestore: ${masjid.title}');

      // Simpan ke Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('Masjid')
          .add(masjidData);

      print('✅ Firestore save successful: ${docRef.id}');

      return Right(docRef.id);
    } catch (e) {
      print('❌ Error creating masjid: $e');
      // Cetak stacktrace juga untuk diagnosis
      try {
        throw e;
      } catch (err, st) {
        print(st);
      }
      return Left("Gagal membuat masjid: $e");
    }
  }
}
