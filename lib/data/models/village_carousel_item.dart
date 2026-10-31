class VillageCarouselItem {
  const VillageCarouselItem(
      {required this.imageUrl,
      required this.name,
      required this.description,
      required this.position});

  final String imageUrl;
  final String name;
  final String description;
  final int position;

  factory VillageCarouselItem.fromJson(Map<String, dynamic> json, Uri base) {
    final image = json['carousel_image'];
    if (image is! String || image.trim().isEmpty) {
      throw const FormatException('Carousel image is missing.');
    }
    var uri = base.resolve(image.trim());
    // Uploaded image URLs can contain the server's localhost address.
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      uri = uri.replace(scheme: base.scheme, host: base.host, port: base.port);
    }
    if (!['http', 'https'].contains(uri.scheme)) {
      throw const FormatException('Invalid carousel image URL.');
    }
    return VillageCarouselItem(
      imageUrl: uri.toString(),
      name: json['carousel_name'] as String? ?? '',
      description: json['carousel_desc'] as String? ?? '',
      position: int.tryParse('${json['carousel_position']}') ?? 0,
    );
  }
}
