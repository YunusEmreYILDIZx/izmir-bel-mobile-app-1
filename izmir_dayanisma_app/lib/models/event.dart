// lib/models/event.dart

class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String location;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });

  /// Veritabanına çevirmek için
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'location': location,
  };

  /// Map’ten Event nesnesi oluşturmak için
  factory Event.fromMap(Map<String, dynamic> map) => Event(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String,
    date: DateTime.parse(map['date'] as String),
    location: map['location'] as String,
  );

  /// copyWith metodu ekleyin
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }
}
