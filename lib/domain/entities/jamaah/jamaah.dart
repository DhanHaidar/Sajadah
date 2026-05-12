class JamaahEntity {
  final String? userId;
  final String? masjidId;
  final String name;
  final String jenisKelamin;
  final String? noHp;
  final String kategori;

  JamaahEntity({
    this.userId,
    this.masjidId,
    required this.name,
    required this.jenisKelamin,
    this.noHp,
    required this.kategori,
  });
}
