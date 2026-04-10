import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/course.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'submission_page.dart';
import 'create_post.dart';

class CoursePage extends StatefulWidget {
  final Course course;
  const CoursePage({super.key, required this.course});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late Future<List<Post>> _feedFuture;
  late Future<Map<String, dynamic>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _refreshData();
  }

  //обновление данных при загрузке и после создания поста
  void _refreshData() {
    setState(() {
      _feedFuture = ApiService.getCourseFeed(widget.course.id);
      _membersFuture = ApiService.getCourseMembers(widget.course.id);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgSecondary,
      appBar: AppBar(
        title: Text(widget.course.code),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Members'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _FeedTab(course: widget.course, feedFuture: _feedFuture),
          _MembersTab(membersFuture: _membersFuture),
        ],
      ),
      floatingActionButton: ApiService.isTeacher
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostPage(courseId: widget.course.id),
                  ),
                );

                if (result == true) {
                  _refreshData();
                }
              },
            )
          : null,
    );
  }
}

class _FeedTab extends StatelessWidget {
  final Course course;
  final Future<List<Post>> feedFuture;
  const _FeedTab({required this.course, required this.feedFuture});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FutureBuilder<List<Post>>(
      future: feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки ленты',
              style: TextStyle(color: c.textSecondary),
            ),
          );
        }
        final posts = snapshot.data ?? [];
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            course.professor,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${course.memberCount} members',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            posts.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'В этом курсе пока нет постов',
                        style: TextStyle(color: c.textTertiary),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PostCard(
                          post: posts[index],
                          onTap: () {
                            if (posts[index].isAssignment) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubmissionPage(post: posts[index]),
                                ),
                              );
                            } else {
                              _showPostDetail(context, posts[index]);
                            }
                          },
                        ),
                        childCount: posts.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  void _showPostDetail(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDetailSheet(post: post),
    );
  }
}

class _PostDetailSheet extends StatelessWidget {
  final Post post;
  const _PostDetailSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: c.bgPrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${post.authorName} • ${post.timeAgo}',
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: c.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final Future<Map<String, dynamic>> membersFuture;
  const _MembersTab({required this.membersFuture});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FutureBuilder<Map<String, dynamic>>(
      future: membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          );
        }
        final data = snapshot.data ?? {};
        final teacher = data['teacher'] as User?;
        final students = (data['students'] as List?)?.cast<User>() ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: c.bgPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${students.length + (teacher != null ? 1 : 0)} participants',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (teacher != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Teacher',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              _MemberTile(user: teacher),
              const SizedBox(height: 20),
            ],
            if (students.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ...students.map((s) => _MemberTile(user: s)),
            ],
          ],
        );
      },
    );
  }
}

class _MemberTile extends StatelessWidget {
  final User user;
  const _MemberTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: user.isTeacher ? c.primaryLight : c.bgTertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 20,
              color: user.isTeacher ? AppTheme.primary : c.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 12, color: c.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
