class DonasiEntity {
  final String? id;
  final String? masjidId;
  final String title;
  final String description;
  final double targetAmount;
  final double collectedAmount;
  final DateTime endDate;
  final String? imageUrl;

  DonasiEntity({
    this.id,
    this.masjidId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.collectedAmount,
    required this.endDate,
    this.imageUrl,
  });
}
