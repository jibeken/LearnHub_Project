import 'package:flutter/material.dart';
import '../app.dart';   
import '../core/theme.dart';
// import '../core/strings.dart';
import '../services/api_service.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  bool _loading          = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);
  try {
    await ApiService.createCourse(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar( 
        content: Text('Course created!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true); 
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating, 
      ));
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) => Scaffold(
        backgroundColor: c.bgSecondary,
        appBar: AppBar(
          title: const Text('Create Course'),
          leading: const BackButton(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.menu_book_rounded, size: 30, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('New Course',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                          color: c.textPrimary, letterSpacing: -0.4)),
                    const SizedBox(height: 6),
                    Text('Fill in the details to create your course',
                      style: TextStyle(fontSize: 14, color: c.textSecondary)),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: c.bgPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          Text('Course Title',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                                color: c.textPrimary)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(fontSize: 15, color: c.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. Introduction to Computer Science',
                              hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
                              fillColor: c.bgTertiary,
                              filled: true,
                              prefixIcon: Icon(Icons.title_rounded, size: 18, color: c.textTertiary),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: c.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.danger),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.danger),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter a title'
                                : null,
                          ),

                          const SizedBox(height: 20),

                          Text('Description',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                                color: c.textPrimary)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            style: TextStyle(fontSize: 15, color: c.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Describe what students will learn...',
                              hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
                              fillColor: c.bgTertiary,
                              filled: true,
                              alignLabelWithHint: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: c.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.danger),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.danger),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter a description'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.add_rounded, size: 20),
                        label: Text(_loading ? 'Creating...' : 'Create Course'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}