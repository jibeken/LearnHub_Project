import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: c.bgPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AuthorAvatar(
                    name: post.authorName,
                    isTeacher: post.type == 'announcement',
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      Text(
                        'Posted ${post.timeAgo}',
                        style: TextStyle(fontSize: 12, color: c.textTertiary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _PostTypeIcon(type: post.type),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.dueDate != null) ...[
                const SizedBox(height: 10),
                _DueBadge(dueDate: post.dueDate!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String name;
  final bool isTeacher;
  const _AuthorAvatar({required this.name, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isTeacher ? c.primaryLight : c.bgTertiary,
        shape: BoxShape.circle,
      ),
      child: isTeacher
          ? const Icon(Icons.person_rounded, size: 18, color: AppTheme.primary)
          : Center(
              child: Text(
                name
                    .split(' ')
                    .take(2)
                    .map((w) => w.isNotEmpty ? w[0] : '')
                    .join(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
    );
  }
}

class _PostTypeIcon extends StatelessWidget {
  final String type;
  const _PostTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    switch (type) {
      case 'assignment':
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.assignment_outlined,
            size: 16,
            color: AppTheme.primary,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.bgTertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.campaign_outlined,
            size: 16,
            color: c.textSecondary,
          ),
        );
    }
  }
}

class _DueBadge extends StatelessWidget {
  final DateTime dueDate;
  const _DueBadge({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isOverdue = dueDate.isBefore(DateTime.now());
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final label = 'Due ${months[dueDate.month]} ${dueDate.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? c.dangerLight : c.warningLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isOverdue ? AppTheme.danger : AppTheme.warning,
        ),
      ),
    );
  }
}
