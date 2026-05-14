class CashFlow {
  int? id;
  int projectId;
  int year;
  double revenue;
  double expenses;
  String description;

  CashFlow({
    this.id,
    required this.projectId,
    required this.year,
    required this.revenue,
    required this.expenses,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'year': year,
      'revenue': revenue,
      'expenses': expenses,
      'description': description,
    };
  }

  factory CashFlow.fromMap(Map<String, dynamic> map) {
    return CashFlow(
      id: map['id'],
      projectId: map['projectId'],
      year: map['year'],
      revenue: map['revenue'],
      expenses: map['expenses'],
      description: map['description'],
    );
  }
}