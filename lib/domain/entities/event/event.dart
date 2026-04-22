class EventEntity {
  final String title;
  final String deskripsi;
  final String? speaker;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;

  EventEntity({
    required this.title,
    required this.deskripsi,
    this.speaker,
    required this.dateTime,
    required this.location,
    this.imageUrl,
  });
}
