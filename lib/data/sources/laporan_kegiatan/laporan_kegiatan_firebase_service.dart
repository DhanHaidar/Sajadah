import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LaporanKegiatanFirebaseService {
  Future<Either> createLaporanKegiatan(
    EventModel laporan, {
    File? imageFile,
    File? documentFile,
    String? documentName,
  });
}

class LaporanKegiatanFirebaseServiceImpl
    extends LaporanKegiatanFirebaseService {
  static const String _collectionName = 'Laporan';

  Future<String?> _uploadFile({
    required File file,
    required String folder,
  }) async {
    final storage = Supabase.instance.client.storage.from('SajadaApp');
    final extension = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$folder/$fileName';

    try {
      await storage.upload(path, file);
    } catch (_) {
      final bytes = await file.readAsBytes();
      await storage.uploadBinary(path, bytes);
    }

    return storage.getPublicUrl(path);
  }

  @override
  Future<Either> createLaporanKegiatan(
    EventModel laporan, {
    File? imageFile,
    File? documentFile,
    String? documentName,
  }) async {
    try {
      String? imageUrl;
      String? docUrl;

      if (imageFile != null) {
        imageUrl = await _uploadFile(file: imageFile, folder: 'report_images');
      }

      if (documentFile != null) {
        docUrl = await _uploadFile(
          file: documentFile,
          folder: 'report_documents',
        );
      }

      final reportData = laporan.toJson();
      if (imageUrl != null) reportData['imageUrl'] = imageUrl;
      if (docUrl != null) reportData['documentUrl'] = docUrl;
      if (documentName != null) reportData['documentName'] = documentName;

      final masjidId = laporan.masjidId;
      final collection = masjidId == null || masjidId.isEmpty
          ? FirebaseFirestore.instance.collection(_collectionName)
          : FirebaseFirestore.instance
                .collection('Masjid')
                .doc(masjidId)
                .collection(_collectionName);

      final docRef = await collection.add(reportData);
      return Right(docRef.id);
    } catch (e) {
      return Left('Gagal menyimpan laporan kegiatan: $e');
    }
  }
}
