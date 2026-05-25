import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/data/models/donasi/donasi_model.dart'; // Import Model Donasi

abstract class MasjidFirebaseService {
  Future<Either> getAllMasjids();
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile});
  
  // Tambahan kontrak untuk Donasi
  Future<Either> createDonation(String masjidId, DonasiModel donasi, {File? imageFile});
}

class MasjidFirebaseServiceImpl extends MasjidFirebaseService {
  
  @override
  Future<Either> getAllMasjids() async {
    try {
      List<MasjidEntity> masjids = [];
      var data = await FirebaseFirestore.instance
          .collection("Masjid")
          .orderBy('createdAt', descending: true)
          .get();

      for (var element in data.docs) {
        final raw = element.data();
        var masjidModel = MasjidModel.fromJson(raw, docId: element.id);
        masjids.add(masjidModel.toEntity());
      }
      return Right(masjids);
    } catch (e) {
      return Left("Gagal mengambil masjids: $e");
    }
  }

  @override
  Future<Either> createMasjid(MasjidModel masjid, {File? imageFile}) async {
    try {
      String? uploadedImageUrl;

      if (imageFile != null) {
        try {
          final extension = imageFile.path.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
          final path = 'masjid_images/$fileName';

          await Supabase.instance.client.storage
              .from('SajadaApp')
              .upload(path, imageFile);

          uploadedImageUrl = Supabase.instance.client.storage
              .from('SajadaApp')
              .getPublicUrl(path);
        } catch (storageError) {
          print('⚠️ Supabase Storage error: $storageError');
        }
      }

      final masjidData = masjid.toJson();
      masjidData['createdAt'] = FieldValue.serverTimestamp();
      if (uploadedImageUrl != null) {
        masjidData['imageUrl'] = uploadedImageUrl;
      }

      final docRef = await FirebaseFirestore.instance
          .collection('Masjid')
          .add(masjidData);

      return Right(docRef.id);
    } catch (e) {
      return Left("Gagal membuat masjid: $e");
    }
  }

  // FUNGSI BARU UNTUK MEMBUAT DONASI DI DALAM MASJID
  @override
  Future<Either> createDonation(String masjidId, DonasiModel donasi, {File? imageFile}) async {
    try {
      String? uploadedImageUrl;

      // 1. Upload Gambar Banner Donasi ke Supabase (Jika ada)
      if (imageFile != null) {
        try {
          final extension = imageFile.path.split('.').last;
          final fileName = 'donasi_${DateTime.now().millisecondsSinceEpoch}.$extension';
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
          print('⚠️ Supabase Storage error (lanjut tanpa gambar): $storageError');
        }
      }

      // 2. Siapkan data JSON
      final donasiData = donasi.toJson();
      donasiData['createdAt'] = FieldValue.serverTimestamp();
      donasiData['masjidId'] = masjidId; // Sambungkan donasi ini ke Masjid tertentu
      if (uploadedImageUrl != null) {
        donasiData['imageUrl'] = uploadedImageUrl;
      }

      print('💾 Saving Donation to Firestore: ${donasi.title}');

      // 3. Simpan ke koleksi 'Donasi' di Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('Donasi')
          .add(donasiData);

      print('✅ Firestore Donation save successful: ${docRef.id}');
      return Right(docRef.id);
      
    } catch (e) {
      print('❌ Error creating donation: $e');
      return Left("Gagal membuat donasi: $e");
    }
  }
}