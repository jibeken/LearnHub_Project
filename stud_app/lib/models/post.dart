// models/post.dart
import 'user.dart';

class Comment {
  final int id;
  final int postId;
  final User author;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  String get authorName => author.name.isNotEmpty ? author.name : author.email;
  // content — алиас text для обратной совместимости
  String get content => text;
  bool get isTeacher => author.role == 'teacher';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    return '${diff.inDays} дн. назад';
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['post'] as int,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class PostAttachment {
  final int id;
  final String fileName;
  final String? url;

  PostAttachment({required this.id, required this.fileName, this.url});

  bool get isImage {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool get isAudio {
    final ext = fileName.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext);
  }

  factory PostAttachment.fromJson(Map<String, dynamic> json) {
    return PostAttachment(
      id: json['id'] as int? ?? 0,
      fileName: json['file_name'] as String? ?? '',
      url: json['url'] as String?,
    );
  }
}

class Post {
  final int id;
  final String type;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? points;
  final int commentCount;
  final List<Comment> comments;
  final List<PostAttachment> attachments;

  Post({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.dueDate,
    this.points,
    this.commentCount = 0,
    this.comments = const [],
    this.attachments = const [],
  });

  bool get isAssignment => type == 'assignment';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    return '${diff.inDays} дн. назад';
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    String authorName = 'Преподаватель';
    final authorData = json['author'];
    if (authorData is Map<String, dynamic>) {
      authorName =
          authorData['name'] as String? ??
          authorData['username'] as String? ??
          authorData['email'] as String? ??
          'Преподаватель';
    } else if (authorData is String) {
      authorName = authorData;
    }

    return Post(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'announcement',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorName: authorName,
      createdAt: DateTime.parse(json['created_at'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      points: json['points'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      attachments:
          (json['files'] as List<dynamic>?)
              ?.map((f) => PostAttachment.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
