import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class SelectCoursePage extends StatefulWidget {
  const SelectCoursePage({super.key});

  @override
  State<SelectCoursePage> createState() => _SelectCoursePageState();
}

class _SelectCoursePageState extends State<SelectCoursePage> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = ApiService.getCourses();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgSecondary,
      appBar: AppBar(
        title: const Text('Выберите курс'),
        backgroundColor: c.bgPrimary,
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          
          final courses = snapshot.data ?? [];
          
          if (courses.isEmpty) {
            return const Center(
              child: Text('У вас нет курсов. Сначала создайте курс.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(course.title),
                  subtitle: course.description.isNotEmpty
                      ? Text(course.description, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, course.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}