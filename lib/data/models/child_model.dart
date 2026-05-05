class ChildModel {
  final String name;
  final String studentClass;
  final String board;
  final List<String> schoolDays;

  ChildModel({
    required this.name,
    required this.studentClass,
    required this.board,
    required this.schoolDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'class': studentClass,
      'board': board,
      'schoolDays': schoolDays,
    };
  }

  factory ChildModel.fromMap(Map<dynamic, dynamic> map) {
    return ChildModel(
      name: map['name'],
      studentClass: map['class'],
      board: map['board'],
      schoolDays: List<String>.from(map['schoolDays']),
    );
  }
}