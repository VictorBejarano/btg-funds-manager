class Fund {
  final String id;
  final String name;
  final double minAmount;
  final String category;

  const Fund({
    required this.id,
    required this.name,
    required this.minAmount,
    required this.category,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'] as String,
      name: json['name'] as String,
      minAmount: (json['minAmount'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minAmount': minAmount,
      'category': category,
    };
  }
}
