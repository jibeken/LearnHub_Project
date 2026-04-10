import 'package:flutter/material.dart';
import '../app.dart';
import '../core/theme.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  List<Comment> _comments = [];
  bool _loadingComments = true;
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await ApiService.getComments(widget.post.id);
      if (mounted) setState(() { _comments = comments; _loadingComments = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sendingComment = true);
    try {
      final comment = await ApiService.addComment(widget.post.id, text);
      _commentCtrl.clear();
      _focusNode.unfocus();
      if (mounted) {
        setState(() => _comments.add(comment));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        return AlertDialog(
          backgroundColor: c.bgPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Удалить комментарий?', style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          content: Text('Это действие нельзя отменить.', style: TextStyle(color: c.textSecondary, fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Отмена', style: TextStyle(color: c.textSecondary))),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить', style: TextStyle(color: AppTheme.danger)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await ApiService.deleteComment(comment.id);
      if (mounted) setState(() => _comments.removeWhere((c) => c.id == comment.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeNotifier, languageNotifier]),
      builder: (context, _) {
        final c = context.colors;
        final post = widget.post;
        final isTeacher = ApiService.isTeacher;
        final currentUserId = ApiService.currentUser?.id;

        return Scaffold(
          backgroundColor: c.bgSecondary,
          appBar: AppBar(
            backgroundColor: c.bgPrimary,
            elevation: 0,
            title: Text(
              post.type == 'assignment' ? 'Задание' : 'Объявление',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary),
            ),
            leading: const BackButton(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: c.border),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    //карточка поста
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: c.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            _Avatar(name: post.authorName, isTeacher: true),
                            const SizedBox(width: 10),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(post.authorName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                              Text(post.timeAgo, style: TextStyle(fontSize: 12, color: c.textTertiary)),
                            ]),
                          ]),
                          const SizedBox(height: 16),
                          Text(post.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.3)),
                          const SizedBox(height: 10),
                          Text(post.content, style: TextStyle(fontSize: 15, color: c.textSecondary, height: 1.6)),
                          //задания
                          if (post.isAssignment) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              if (post.dueDate != null)
                                _InfoBadge(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'До ${post.dueDate!.day}.${post.dueDate!.month}.${post.dueDate!.year}',
                                  isOverdue: post.dueDate!.isBefore(DateTime.now()),
                                ),
                              if (post.points != null)
                                _InfoBadge(
                                  icon: Icons.star_rounded,
                                  label: '${post.points} баллов',
                                  isOverdue: false,
                                ),
                            ]),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    //заголовок комментариев
                    Row(children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 18, color: c.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Комментарии (${_comments.length})',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    //список комментариев
                    if (_loadingComments)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ))
                    else if (_comments.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        alignment: Alignment.center,
                        child: Column(children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 40, color: c.textTertiary),
                          const SizedBox(height: 8),
                          Text('Комментариев пока нет', style: TextStyle(fontSize: 14, color: c.textTertiary)),
                          Text('Будьте первым!', style: TextStyle(fontSize: 13, color: c.textTertiary)),
                        ]),
                      )
                    else
                      ..._comments.map((comment) {
                        final canDelete = isTeacher || comment.author.id == currentUserId;
                        return _CommentTile(
                          comment: comment,
                          canDelete: canDelete,
                          onDelete: () => _deleteComment(comment),
                        );
                      }),

                    const SizedBox(height: 80), 
                  ],
                ),
              ),

              //поле ввода комментария
              Container(
                decoration: BoxDecoration(
                  color: c.bgPrimary,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                padding: EdgeInsets.only(
                  left: 16, right: 16,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Row(children: [
                  _Avatar(
                    name: ApiService.currentUser?.name ?? '?',
                    isTeacher: isTeacher,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(fontSize: 14, color: c.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Написать комментарий...',
                        hintStyle: TextStyle(fontSize: 14, color: c.textTertiary),
                        fillColor: c.bgSecondary,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: c.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: c.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sendingComment
                      ? const SizedBox(
                          width: 38, height: 38,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        )
                      : GestureDetector(
                          onTap: _sendComment,
                          child: Container(
                            width: 38, height: 38,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

//тайл комментария
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: comment.authorName, isTeacher: comment.isTeacher, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.bgPrimary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          comment.authorName,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary),
                        ),
                        if (comment.isTeacher) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Учитель', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Text(comment.text, style: TextStyle(fontSize: 14, color: c.textPrimary, height: 1.4)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Row(children: [
                    Text(comment.timeAgo, style: TextStyle(fontSize: 11, color: c.textTertiary)),
                    if (canDelete) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onDelete,
                        child: Text('Удалить', style: TextStyle(fontSize: 11, color: AppTheme.danger.withValues(alpha: 0.7))),
                      ),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//aватар
class _Avatar extends StatelessWidget {
  final String name;
  final bool isTeacher;
  final double size;

  const _Avatar({required this.name, this.isTeacher = false, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initials = name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: isTeacher ? AppTheme.primary.withValues(alpha: 0.12) : c.bgTertiary,
        shape: BoxShape.circle,
      ),
      child: isTeacher
          ? Icon(Icons.person_rounded, size: size * 0.5, color: AppTheme.primary)
          : Center(
              child: Text(
                initials,
                style: TextStyle(fontSize: size * 0.35, fontWeight: FontWeight.w600, color: c.textSecondary),
              ),
            ),
    );
  }
}

//бейдж (дедлайн / баллы)
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOverdue;

  const _InfoBadge({required this.icon, required this.label, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isOverdue ? AppTheme.danger : AppTheme.warning;
    final bg = isOverdue ? c.dangerLight : c.warningLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}