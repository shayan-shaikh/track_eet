class MediaItem {
  int? id;
  String name;
  String description;
  String author;
  double rating;
  String type;
  String? imagePath;
  DateTime startedAt;
  DateTime? endedAt;

  MediaItem({
    this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.rating,
    required this.type,
    this.imagePath,
    required this.startedAt,
    this.endedAt
  });

  MediaItem copyWith({
  int? id,
  String? name,
  String? description,
  String? author,
  double? rating,
  String? type,
  String? imagePath,
  DateTime? startedAt,
  DateTime? endedAt,
}) {
  return MediaItem(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    author: author ?? this.author,
    rating: rating ?? this.rating,
    type: type ?? this.type,
    imagePath: imagePath ?? this.imagePath,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'rating': rating,
      'type': type,
      'imagePath': imagePath,
      'startedAt': startedAt.toIso8601String(),
      'endedAt' : endedAt?.toIso8601String()
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
  return MediaItem(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    author: map['author'],
    rating: map['rating'],
    type: map['type'],
    imagePath: map['imagePath'],
    startedAt: DateTime.parse(map['startedAt']), 
    endedAt: map['endedAt'] != null ? DateTime.parse(map['endedAt']) : null, 
  );
}
}