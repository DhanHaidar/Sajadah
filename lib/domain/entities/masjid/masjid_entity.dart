class MasjidEntity {
  final String? id;
  final String title;
  final String location;
  final String? imageUrl;

  MasjidEntity({
    this.id,
    required this.title,
    required this.location,
    this.imageUrl,
  });
}
