import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../core/theme.dart';
import '../models/post.dart';
import '../models/submission.dart';
import '../services/api_service.dart';

class SubmissionPage extends StatefulWidget {
  final Post post;
  const SubmissionPage({super.key, required this.post});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  final _commentCtrl = TextEditingController();
  final _submitCommentCtrl = TextEditingController();

  //файлы для сдачи работы
  List<PlatformFile> _pickedFiles = [];

  List<Comment> _comments = [];
  bool _loadingComments = true;
  bool _sending = false;
  bool _submitting = false;
  Submission? _mySubmission;

  @override
  void initState() {
    super.initState();
    _loadComments();
    if (!ApiService.isTeacher) _loadMySubmission();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _submitCommentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMySubmission() async {
    try {
      final subs = await ApiService.getSubmissions(widget.post.id);
      final myId = ApiService.currentUser?.id;
      final mine = subs.where((s) => s.studentId == myId).toList();
      if (mounted && mine.isNotEmpty) setState(() => _mySubmission = mine.first);
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    try {
      final comments = await ApiService.getComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _comments = List.from(widget.post.comments);
        _loadingComments = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final comment = await ApiService.addComment(widget.post.id, text);
      if (!mounted) return;
      setState(() {
        _comments.add(comment);
        _commentCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  //один метод для файлов и изображений
  Future<void> _pickFiles({bool imagesOnly = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: imagesOnly ? FileType.image : FileType.any,
    );
    if (result != null) setState(() => _pickedFiles = result.files);
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  Future<void> _submitAssignment() async {
    if (_pickedFiles.isEmpty && _submitCommentCtrl.text.trim().isEmpty) {
      _showError('Добавьте файл или комментарий перед отправкой');
      return;
    }
    setState(() => _submitting = true);
    try {
      final submission = await ApiService.submitAssignment(
        postId: widget.post.id,
        comment: _submitCommentCtrl.text.trim().isEmpty
            ? null
            : _submitCommentCtrl.text.trim(),
        files: _pickedFiles.isNotEmpty ? _pickedFiles : null,
      );
      if (!mounted) return;
      setState(() {
        _mySubmission = submission;
        _pickedFiles.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Задание отправлено!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Ошибка отправки: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить комментарий?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.deleteComment(comment.id);
      setState(() => _comments.removeWhere((c) => c.id == comment.id));
    } catch (e) {
      _showError('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final post = widget.post;
    final isTeacher = ApiService.isTeacher;

    return Scaffold(
      backgroundColor: c.bgSecondary,
      appBar: AppBar(
        backgroundColor: c.bgPrimary,
        title: Text(
          post.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PostCard(post: post),
                const SizedBox(height: 16),
                if (isTeacher)
                  _TeacherSubmissionsSection(postId: post.id)
                else if (_mySubmission != null)
                  _SubmittedBanner(submission: _mySubmission!)
                else
                  _SubmitSection(
                    pickedFiles: _pickedFiles,
                    commentCtrl: _submitCommentCtrl,
                    onPickFiles: () => _pickFiles(),
                    onPickImages: () => _pickFiles(imagesOnly: true),
                    onRemoveFile: _removeFile,
                    onSubmit: _submitting ? null : _submitAssignment,
                    submitting: _submitting,
                  ),
                const SizedBox(height: 16),
                _CommentsSection(
                  comments: _comments,
                  loadingComments: _loadingComments,
                  currentUserId: ApiService.currentUser?.id,
                  isTeacher: isTeacher,
                  onDelete: _deleteComment,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _CommentInputBar(
            ctrl: _commentCtrl,
            sending: _sending,
            onSend: _sendComment,
            onAttach: () => _pickFiles(),
          ),
        ],
      ),
    );
  }
}

//карточка задания
class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            post.content,
            style: TextStyle(fontSize: 15, color: c.textSecondary, height: 1.6),
          ),
          if (post.dueDate != null || post.points != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (post.dueDate != null)
                  _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: 'До ${post.dueDate!.day}.${post.dueDate!.month}.${post.dueDate!.year}',
                    color: AppTheme.warning,
                    bgColor: c.warningLight,
                  ),
                if (post.points != null)
                  _InfoChip(
                    icon: Icons.star_outline_rounded,
                    label: '${post.points} баллов',
                    color: AppTheme.primary,
                    bgColor: c.primaryLight,
                  ),
              ],
            ),
          ],
          if (post.attachments.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Прикреплённые материалы:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.attachments.map((a) => _AttachmentChip(attachment: a)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

//чип вложения поста
class _AttachmentChip extends StatelessWidget {
  final PostAttachment attachment;
  const _AttachmentChip({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = attachment.isImage
        ? Icons.image_outlined
        : attachment.isAudio
            ? Icons.audiotrack_outlined
            : Icons.insert_drive_file_outlined;

    return GestureDetector(
      onTap: () {
        if (attachment.url != null && attachment.isImage) {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(child: Image.network(attachment.url!, fit: BoxFit.contain)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.textSecondary),
            const SizedBox(width: 6),
            Text(attachment.fileName, style: TextStyle(fontSize: 12, color: c.textSecondary), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

//форма сдачи работы студентом
class _SubmitSection extends StatelessWidget {
  final List<PlatformFile> pickedFiles;
  final TextEditingController commentCtrl;
  final VoidCallback onPickFiles;
  final VoidCallback onPickImages;
  final void Function(int) onRemoveFile;
  final VoidCallback? onSubmit;
  final bool submitting;

  const _SubmitSection({
    required this.pickedFiles,
    required this.commentCtrl,
    required this.onPickFiles,
    required this.onPickImages,
    required this.onRemoveFile,
    required this.onSubmit,
    required this.submitting,
  });

  bool _isImage(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ваша работа', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImages,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Фото'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFiles,
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  label: const Text('Файл'),
                ),
              ),
            ],
          ),
          if (pickedFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...pickedFiles.asMap().entries.map((entry) {
              final i = entry.key;
              final file = entry.value;
              final name = file.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.bgTertiary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: _isImage(name)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(File(file.path!), width: 40, height: 40, fit: BoxFit.cover),
                          )
                        : Icon(Icons.insert_drive_file_outlined, color: c.textSecondary),
                    title: Text(name, style: TextStyle(fontSize: 13, color: c.textPrimary), overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppTheme.danger),
                      onPressed: () => onRemoveFile(i),
                    ),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: commentCtrl,
            minLines: 2,
            maxLines: 4,
            style: TextStyle(fontSize: 14, color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'Комментарий к работе (необязательно)',
              hintStyle: TextStyle(color: c.textTertiary),
              fillColor: c.bgTertiary,
              filled: true,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Отправить задание'),
            ),
          ),
        ],
      ),
    );
  }
}

//баннер когда студент уже сдал работу
class _SubmittedBanner extends StatelessWidget {
  final Submission submission;
  const _SubmittedBanner({required this.submission});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
              const SizedBox(width: 10),
              const Text('Работа отправлена!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.success)),
            ],
          ),
          if (submission.isGraded) ...[
            const SizedBox(height: 8),
            Text('Оценка: ${submission.grade} баллов', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.success)),
            if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(submission.feedback!, style: TextStyle(fontSize: 13, color: c.textSecondary)),
            ],
          ],
          if (submission.allFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Прикреплённые файлы:', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...submission.allFiles.map(
              (f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: _FilePreviewTile(file: f)),
            ),
          ],
        ],
      ),
    );
  }
}

//превью одного файла
class _FilePreviewTile extends StatelessWidget {
  final SubmissionFile file;
  const _FilePreviewTile({required this.file});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () {
        if (file.isImage && file.url != null) {
          showDialog(
            context: context,
            builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(file.url!, fit: BoxFit.contain))),
          );
        }
      },
      child: Row(
        children: [
          if (file.isImage && file.url != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(file.url!, width: 40, height: 40, fit: BoxFit.cover),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: c.bgTertiary, borderRadius: BorderRadius.circular(6)),
              child: Icon(file.isAudio ? Icons.audiotrack_outlined : Icons.insert_drive_file_outlined, color: c.textSecondary, size: 20),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(file.fileName, style: TextStyle(fontSize: 13, color: c.textPrimary), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

//список сданных работ для учителя
class _TeacherSubmissionsSection extends StatefulWidget {
  final int postId;
  const _TeacherSubmissionsSection({required this.postId});

  @override
  State<_TeacherSubmissionsSection> createState() => _TeacherSubmissionsSectionState();
}

class _TeacherSubmissionsSectionState extends State<_TeacherSubmissionsSection> {
  late Future<List<Submission>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getSubmissions(widget.postId);
  }

  void _refresh() => setState(() => _future = ApiService.getSubmissions(widget.postId));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FutureBuilder<List<Submission>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        final submissions = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.bgPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Работы студентов', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const Spacer(),
                  Text('${submissions.length} сдали', style: TextStyle(fontSize: 13, color: c.textTertiary)),
                ],
              ),
              const SizedBox(height: 12),
              if (submissions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('Пока никто не сдал.', style: TextStyle(color: c.textTertiary))),
                )
              else
                ...submissions.map((s) => _GradingTile(submission: s, onGraded: _refresh)),
            ],
          ),
        );
      },
    );
  }
}

//тайл оценивания одной работы студента
class _GradingTile extends StatefulWidget {
  final Submission submission;
  final VoidCallback onGraded;
  const _GradingTile({required this.submission, required this.onGraded});

  @override
  State<_GradingTile> createState() => _GradingTileState();
}

class _GradingTileState extends State<_GradingTile> {
  bool _expanded = false;
  bool _saving = false;
  bool _showFiles = false;
  final _gradeCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _gradeCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    final grade = int.tryParse(_gradeCtrl.text.trim());
    if (grade == null || grade < 0 || grade > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите оценку от 0 до 100'), backgroundColor: AppTheme.danger, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.gradeSubmission(widget.submission.id, grade, _feedbackCtrl.text.trim());
      if (!mounted) return;
      setState(() => _expanded = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оценка сохранена!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
      );
      widget.onGraded();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = widget.submission;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: c.bgPrimary,
              child: Text(
                s.studentName.isNotEmpty ? s.studentName[0].toUpperCase() : '?',
                style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            title: Text(s.studentName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
            subtitle: s.comment != null && s.comment!.isNotEmpty
                ? Text(s.comment!, style: TextStyle(fontSize: 12, color: c.textTertiary))
                : null,
            trailing: s.isGraded
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: c.successLight, borderRadius: BorderRadius.circular(8)),
                    child: Text('${s.grade}/100', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.success)),
                  )
                : TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Отмена' : 'Оценить',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
          if (s.allFiles.isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _showFiles = !_showFiles),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.attach_file_rounded, size: 16, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text('${s.allFiles.length} файл(а)', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                    const Spacer(),
                    Icon(_showFiles ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: c.textSecondary),
                  ],
                ),
              ),
            ),
            if (_showFiles)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: s.allFiles.map((f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: _FilePreviewTile(file: f))).toList(),
                ),
              ),
          ],
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _gradeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Оценка (0–100)',
                      fillColor: c.bgPrimary,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _feedbackCtrl,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Комментарий (необязательно)',
                      fillColor: c.bgPrimary,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveGrade,
                      child: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Сохранить оценку'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

//список комментариев к заданию
class _CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final bool loadingComments;
  final int? currentUserId;
  final bool isTeacher;
  final void Function(Comment) onDelete;

  const _CommentsSection({
    required this.comments,
    required this.loadingComments,
    required this.currentUserId,
    required this.isTeacher,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Комментарии класса', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textSecondary)),
          ),
          if (loadingComments)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
            )
          else if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Комментариев пока нет.', style: TextStyle(color: c.textTertiary, fontSize: 14)),
            )
          else
            ...comments.map((comment) {
              final canDelete = isTeacher || comment.author.id == currentUserId;
              return _CommentTile(comment: comment, canDelete: canDelete, onDelete: () => onDelete(comment));
            }),
        ],
      ),
    );
  }
}

//один комментарий
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool canDelete;
  final VoidCallback onDelete;
  const _CommentTile({required this.comment, required this.canDelete, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: comment.isTeacher ? c.primaryLight : c.bgTertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 16, color: comment.isTeacher ? AppTheme.primary : c.textTertiary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
                    const SizedBox(width: 6),
                    Text(comment.timeAgo, style: TextStyle(fontSize: 12, color: c.textTertiary)),
                    if (canDelete) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Text('Удалить', style: TextStyle(fontSize: 11, color: AppTheme.danger)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(comment.text, style: TextStyle(fontSize: 14, color: c.textPrimary, height: 1.5)),
                const SizedBox(height: 12),
                Divider(height: 1, color: c.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//поле ввода комментария внизу экрана
class _CommentInputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _CommentInputBar({required this.ctrl, required this.sending, required this.onSend, required this.onAttach});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(color: c.bgPrimary, border: Border(top: BorderSide(color: c.border))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: TextStyle(fontSize: 15, color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Написать комментарий...',
                hintStyle: TextStyle(color: c.textTertiary),
                fillColor: c.bgTertiary,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: sending
                  ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

//чип с иконкой и текстом (дата дедлайна, баллы)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  const _InfoChip({required this.icon, required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}