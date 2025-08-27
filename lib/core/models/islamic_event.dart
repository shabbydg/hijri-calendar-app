class IslamicEvent {
  final String title;
  final String description;
  final String location;
  final String category;
  final bool isImportant;

  const IslamicEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    this.isImportant = false,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      isImportant: json['isImportant'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'isImportant': isImportant,
    };
  }
}
