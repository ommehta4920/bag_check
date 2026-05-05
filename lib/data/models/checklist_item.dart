class ChecklistItem {
  final String name;
  bool isChecked;

  ChecklistItem({
    required this.name,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isChecked': isChecked,
    };
  }

  factory ChecklistItem.fromMap(Map<dynamic, dynamic> map) {
    return ChecklistItem(
      name: map['name'],
      isChecked: map['isChecked'],
    );
  }
}