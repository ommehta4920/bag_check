class TimetableModel {
  final Map<String, List<String>> timetable;

  TimetableModel({required this.timetable});

  Map<String, dynamic> toMap() {
    return timetable;
  }

  factory TimetableModel.fromMap(Map<dynamic, dynamic> map) {
    return TimetableModel(
      timetable: map.map(
            (key, value) => MapEntry(
          key,
          List<String>.from(value),
        ),
      ),
    );
  }
}