// models/submission.dart

class SubmissionFile {
  final int id;
  final String fileName;
  final String? url;

  SubmissionFile({required this.id, required this.fileName, this.url});

  factory SubmissionFile.fromJson(Map<String, dynamic> json) {
    return SubmissionFile(
      id: json['id'] as int? ?? 0,
      fileName: json['file_name'] as String? ?? '',
      url: json['url'] as String?,
    );
  }

  bool get isImage {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool get isAudio {
    final ext = fileName.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext);
  }
}

class Submission {
  final int id;
  final int postId;
  final int studentId;
  final String studentName;
  final String? fileUrl;
  final String? fileName;
  final String? comment;
  final DateTime submittedAt;
  final int? grade;
  final String? feedback;
  final String status;
  final List<SubmissionFile> extraFiles;

  Submission({
    required this.id,
    required this.postId,
    required this.studentId,
    required this.studentName,
    this.fileUrl,
    this.fileName,
    this.comment,
    required this.submittedAt,
    this.grade,
    this.feedback,
    this.status = 'pending',
    this.extraFiles = const [],
  });

  bool get isGraded => status == 'graded' || grade != null;

  /// Все файлы: основной + дополнительные
  List<SubmissionFile> get allFiles {
    final result = <SubmissionFile>[];
    if (fileUrl != null && fileName != null) {
      result.add(SubmissionFile(id: -1, fileName: fileName!, url: fileUrl));
    }
    result.addAll(extraFiles);
    return result;
  }

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as int? ?? 0,
      postId: (json['post_id'] ?? json['post']) as int? ?? 0,
      studentId: _parseStudentId(json),
      studentName: _parseStudentName(json),
      fileUrl: json['file_url'] as String? ?? json['file'] as String?,
      fileName: json['file_name'] as String? ?? _fileNameFromPath(json['file']),
      comment: json['comment'] as String? ?? json['text'] as String?,
      submittedAt: _parseDate(json['submitted_at'] ?? json['created_at']),
      grade: json['grade'] as int?,
      feedback: json['feedback'] as String?,
      status: json['status'] as String? ?? 'pending',
      extraFiles:
          (json['extra_files'] as List<dynamic>?)
              ?.map((f) => SubmissionFile.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static int _parseStudentId(Map<String, dynamic> json) {
    if (json['student'] is Map) {
      return (json['student'] as Map<String, dynamic>)['id'] as int? ?? 0;
    }
    return (json['student_id'] ?? json['student']) as int? ?? 0;
  }

  static String _parseStudentName(Map<String, dynamic> json) {
    if (json['student_name'] is String) return json['student_name'] as String;
    if (json['student'] is Map) {
      final s = json['student'] as Map<String, dynamic>;
      return s['name'] as String? ??
          s['username'] as String? ??
          s['email'] as String? ??
          'Unknown';
    }
    if (json['author'] is Map) {
      final a = json['author'] as Map<String, dynamic>;
      return a['name'] as String? ?? a['username'] as String? ?? 'Unknown';
    }
    return json['student_name']?.toString() ?? 'Unknown';
  }

  static String? _fileNameFromPath(dynamic fileValue) {
    if (fileValue is! String || fileValue.isEmpty) return null;
    return fileValue.split('/').last;
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post': postId,
    'student': studentId,
    'student_name': studentName,
    'file_url': fileUrl,
    'file_name': fileName,
    'text': comment,
    'submitted_at': submittedAt.toIso8601String(),
    'grade': grade,
    'feedback': feedback,
    'status': status,
  };
}
