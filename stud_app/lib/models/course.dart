import 'user.dart';

class Course {
  final int id;
  final String title;
  final String code;
  final String professor;
  final User? teacher;
  final String description;
  final int memberCount;
  final bool isEnrolled;
  final String? color;

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.professor,
    this.teacher,
    required this.description,
    this.memberCount = 0,
    this.isEnrolled = false,
    this.color,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final teacherData = json['teacher'];
    var professorName = 'Не указан';
    User? teacherUser;

    if (teacherData is Map<String, dynamic>) {
      professorName =
          teacherData['username'] ?? teacherData['email'] ?? 'Преподаватель';
      teacherUser = User.fromJson(teacherData);
    }

    final rawCount = json['student_count'] ?? json['member_count'] ?? 0;

    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Без названия',
      code: json['code'] ?? 'ID: ${json['id']}',
      professor: professorName,
      teacher: teacherUser,
      description: json['description'] ?? '',
      memberCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount.toString()) ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'professor': professor,
      'description': description,
      'member_count': memberCount,
      'is_enrolled': isEnrolled,
      'color': color,
    };
  }
}
