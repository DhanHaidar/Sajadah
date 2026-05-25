class DonasiModel {
  final String title;
  final String description;
  final double targetAmount;
  final DateTime endDate;
  final String? imageUrl;

  DonasiModel({
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.endDate,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'collectedAmount': 0.0, // Default 0 saat baru dibuat
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}