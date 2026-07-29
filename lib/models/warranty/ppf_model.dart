// ═══════════════════════════════════════════════════════════════════════════
// 📦 PPF Model (Paint Protection Film)
// ═══════════════════════════════════════════════════════════════════════════
class PPFModel {
  final int id;
  final String name;
  final String nameAr;
  final String? description;

  PPFModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
  });

  factory PPFModel.fromJson(Map<String, dynamic> json) {
    return PPFModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
    };
  }
}
