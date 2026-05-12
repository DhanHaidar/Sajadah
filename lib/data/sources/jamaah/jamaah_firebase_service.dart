import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sajadah/data/models/Jamaah/Jamaah.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';

abstract class JamaahFirebaseService {
  //Future<Either> getJamaahs();
  //Future<Either> getAllJamaahs();
  Future<Either> getJamaahsByMasjid(String masjidId);
  Future<Either> createJamaah(JamaahModel jamaah);
  Future<Either> createJamaahForMasjid(String masjidId, JamaahModel jamaah);
}

class JamaahFirebaseServiceImpl extends JamaahFirebaseService {
  @override
  // Future<Either> getJamaahs() async {
  //   try {
  //     List<JamaahEntity> jamaahs = [];
  //     var data = await FirebaseFirestore.instance
  //         .collection("Jamaah")
  //         .orderBy('waktu', descending: true)
  //         .get();
  //     for (var element in data.docs) {
  //       final raw = element.data();
  //       print('JamaahFirebaseServiceImpl: doc=${element.id} raw=$raw');
  //       var jamaahModel = JamaahModel.fromJson(raw);
  //       print(
  //         'JamaahFirebaseServiceImpl: mapped name="${jamaahModel.name}", email="${jamaahModel.email}"',
  //       );
  //       jamaahs.add(jamaahModel.toEntity());
  //     }
  //     return Right(jamaahs);
  //   } catch (e) {
  //     return const Left("An error occurred while fetching jamaahs");
  //   }
  // }
  // @override
  // Future<Either> getAllJamaahs() async {
  //   try {
  //     List<JamaahEntity> jamaahs = [];
  //     // Use collectionGroup to get Jamaahs across all Masjid/{id}/Jamaah subcollections
  //     var data = await FirebaseFirestore.instance
  //         .collectionGroup('Jamaah')
  //         .orderBy('waktu', descending: true)
  //         .get();
  //     for (var element in data.docs) {
  //       final raw = element.data();
  //       // Try to derive masjidId from document path: /Masjid/{masjidId}/Jamaah/{JamaahId}
  //       String? masjidId;
  //       try {
  //         masjidId = element.reference.parent.parent?.id;
  //       } catch (_) {
  //         masjidId = raw['masjidId'] as String?;
  //       }
  //       var jamaahModel = JamaahModel.fromJson(
  //         raw,
  //         docId: element.id,
  //         masjidId: masjidId,
  //       );
  //       jamaahs.add(jamaahModel.toEntity());
  //     }
  //     return Right(jamaahs);
  //   } catch (e) {
  //     return Left("Gagal mengambil jamaahs: $e");
  //   }
  // }
  @override
  Future<Either> getJamaahsByMasjid(String masjidId) async {
    try {
      List<JamaahEntity> jamaahs = [];
      var data = await FirebaseFirestore.instance
          .collection('Masjid')
          .doc(masjidId)
          .collection('Jamaah')
          .orderBy('waktu', descending: true)
          .get();

      print('📥 Found ${data.docs.length} jamaah docs for masjid $masjidId');

      for (var element in data.docs) {
        final raw = element.data();
        print('📄 Jamaah doc ${element.id}: $raw');
        var jamaahModel = JamaahModel.fromJson(
          raw,
          docId: element.id,
          masjidId: masjidId,
        );
        jamaahs.add(jamaahModel.toEntity());
      }

      return Right(jamaahs);
    } catch (e) {
      return Left("Gagal mengambil jamaahs untuk masjid $masjidId: $e");
    }
  }

  @override
  Future<Either> createJamaah(JamaahModel jamaah) async {
    try {
      final jamaahData = jamaah.toJson();
      jamaahData['waktu'] = Timestamp.now();
      print('💾 Saving to Firestore: ${jamaah.name}');
      final docRef = await FirebaseFirestore.instance
          .collection('Jamaah')
          .add(jamaahData);
      print('✅ Firestore save successful: ${docRef.id}');
      return Right(docRef.id);
    } catch (e) {
      print('❌ Error creating jamaah: $e');
      return Left("Gagal membuat jamaah: $e");
    }
  }

  @override
  Future<Either> createJamaahForMasjid(
    String masjidId,
    JamaahModel jamaah,
  ) async {
    try {
      final jamaahData = jamaah.toJson();
      jamaahData['masjidId'] = masjidId;
      jamaahData['waktu'] = Timestamp.now();
      print('💾 Saving to Firestore subcollection: Masjid/$masjidId/Jamaah');
      final docRef = await FirebaseFirestore.instance
          .collection('Masjid')
          .doc(masjidId)
          .collection('Jamaah')
          .add(jamaahData);
      print('✅ Firestore save successful: ${docRef.id}');
      return Right(docRef.id);
    } catch (e) {
      print('❌ Error creating Jamaah for masjid $masjidId: $e');
      return Left('Gagal membuat Jamaah untuk masjid $masjidId: $e');
    }
  }
}
