import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';

class JamaahModel {
  final String? userId;
  final String? masjidId;
  final String? name;
  final String? jenisKelamin;
  final String? noHp;
  final String? kategori;

  JamaahModel({
    this.userId,
    this.masjidId,
    this.name,
    this.jenisKelamin,
    this.noHp,
    this.kategori,
  });

  factory JamaahModel.fromJson(
    Map<String, dynamic> data, {
    String? docId,
    String? masjidId,
  }) {
    //{
    //   // Firestore often stores timestamps under custom keys (here: 'waktu').
    //   // final dynamic waktu =
    //   //     data['waktu'] ??
    //   //     data['dateTime'] ??
    //   //     data['date_time'] ??
    //   //     data['date'] ??
    //   //     data['time'];

    //   // DateTime parsedDate;
    //   // if (waktu == null) {
    //   //   parsedDate = DateTime.now();
    //   // } else if (waktu is Timestamp) {
    //   //   parsedDate = waktu.toDate();
    //   // } else if (waktu is DateTime) {
    //   //   parsedDate = waktu;
    //   // } else if (waktu is String) {
    //   //   parsedDate = DateTime.tryParse(waktu) ?? DateTime.now();
    //   // } else if (waktu is int) {
    //   //   parsedDate = DateTime.fromMillisecondsSinceEpoch(waktu);
    //   // } else {
    //   //   parsedDate = DateTime.now();
    //   }

    return JamaahModel(
      userId: docId,
      masjidId: masjidId ?? (data['masjidId'] as String?),
      name: (data['name'] as String?) ?? (data['nama'] as String?) ?? '',
      jenisKelamin:
          (data['jenisKelamin'] as String?) ??
          (data['jenis_kelamin'] as String?) ??
          '',
      noHp: (data['noHp'] as String?) ?? (data['no_hp'] as String?) ?? '',
      kategori: (data['kategori'] as String?) ?? '',
      // title:
      //     (data['title'] as String?) ??
      //     (data['judul'] as String?) ??
      //     (data['name'] as String?) ??
      //     (data['nama'] as String?) ??
      //     '',
      // deskripsi:
      //     (data['deskripsi'] as String?) ??
      //     (data['description'] as String?) ??
      //     (data['desc'] as String?) ??
      //     '',
      // speaker: (data['speaker'] as String?),
      // dateTime: parsedDate,
      // location:
      //     (data['location'] as String?) ?? (data['lokasi'] as String?) ?? '',
      // imageUrl: (data['imageUrl'] as String?) ?? (data['image'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (jenisKelamin != null) 'jenisKelamin': jenisKelamin,
      if (noHp != null) 'noHp': noHp,
      if (kategori != null) 'kategori': kategori,
      // 'deskripsi': deskripsi,
      // 'speaker': speaker,
      // 'waktu': Timestamp.fromDate(dateTime),
      // 'location': location,
      // 'imageUrl': imageUrl,
      if (masjidId != null) 'masjidId': masjidId,
    };
  }
}

extension JamaahModelX on JamaahModel {
  JamaahEntity toEntity() {
    return JamaahEntity(
      userId: userId,
      masjidId: masjidId,
      name: name ?? '',
      jenisKelamin: jenisKelamin ?? '',
      noHp: noHp,
      kategori: kategori ?? '',
      // location: location,
      // imageUrl: imageUrl,
    );
  }
}
