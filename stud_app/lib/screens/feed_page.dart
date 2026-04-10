import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class FeedPage extends StatefulWidget {
  final int courseId; 
  const FeedPage({super.key, required this.courseId});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = ApiService.getCourseFeed(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = ApiService.isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Обсуждения"),
        actions: [
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () => _showCreatePostDialog(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshPosts(),
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Ошибка: ${snapshot.error}"));
            }

            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Center(child: Text("В этом курсе пока нет постов"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  onTap: () => _showCommentsBottomSheet(posts[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Новый пост",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Заголовок"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Содержание"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ApiService.createPost(
                  courseId: widget.courseId,
                  title: titleController.text,
                  content: contentController.text,
                  type: 'announcement',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _refreshPosts(); 
                }
              },
              child: const Text("Опубликовать"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(Post post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Комментарии",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, i) => ListTile(
                  leading: CircleAvatar(
                    child: Text(post.comments[i].authorName[0]),
                  ),
                  title: Text(post.comments[i].authorName),
                  subtitle: Text(post.comments[i].text),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: "Напишите ответ...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) return;

                      await ApiService.addComment(
                        post.id,
                        commentController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        _refreshPosts();
                      }
                    },
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
