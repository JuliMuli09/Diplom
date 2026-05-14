class Project {
  int? id;
  int userId;
  String name;
  String description;
  double initialInvestment;
  double discountRate;
  DateTime createdAt;

  Project({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.initialInvestment,
    required this.discountRate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'initialInvestment': initialInvestment,
      'discountRate': discountRate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      initialInvestment: map['initialInvestment'],
      discountRate: map['discountRate'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}