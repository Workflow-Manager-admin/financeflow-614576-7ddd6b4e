class SavingsSuggestionModel {
  final String id;
  final String title;
  final String description;
  final double potentialSavings;
  final String category;
  final bool isImplemented;

  SavingsSuggestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.category,
    this.isImplemented = false,
  });

  factory SavingsSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SavingsSuggestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialSavings: json['potentialSavings'] as double,
      category: json['category'] as String,
      isImplemented: json['isImplemented'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'potentialSavings': potentialSavings,
      'category': category,
      'isImplemented': isImplemented,
    };
  }

  SavingsSuggestionModel copyWith({
    String? id,
    String? title,
    String? description,
    double? potentialSavings,
    String? category,
    bool? isImplemented,
  }) {
    return SavingsSuggestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      potentialSavings: potentialSavings ?? this.potentialSavings,
      category: category ?? this.category,
      isImplemented: isImplemented ?? this.isImplemented,
    );
  }
}
