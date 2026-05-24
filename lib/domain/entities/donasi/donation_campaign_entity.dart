class DonationCampaignEntity {
  final String? id; // ID dari campaign donasi (dibuat otomatis oleh database)
  final String masjidId; // Menghubungkan donasi ini ke masjid tertentu
  final String title; // Judul Donasi (ex: "Bakti Sosial Ramadhan")
  final String description; // Deskripsi Donasi
  final double targetAmount; // Target Donasi (ex: 5.000.000)
  final double collectedAmount; // Total yang sudah terkumpul (ex: 4.200.000)
  final DateTime endDate; // Batas Waktu Donasi
  final String? imageUrl; // URL Gambar Banner Donasi

  DonationCampaignEntity({
    this.id,
    required this.masjidId,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.collectedAmount = 0.0, // Default 0 saat baru dibuat
    required this.endDate,
    this.imageUrl,
  });

  // Fungsi tambahan untuk menghitung persentase progress (berguna untuk UI nanti)
  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (collectedAmount / targetAmount).clamp(0.0, 1.0);
  }
}