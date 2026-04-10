import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../core/theme.dart';
import '../core/strings.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class JoinCoursePage extends StatefulWidget {
  final bool isFirstTime;
  const JoinCoursePage({super.key, this.isFirstTime = false});

  @override
  State<JoinCoursePage> createState() => _JoinCoursePageState();
}

class _JoinCoursePageState extends State<JoinCoursePage> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _searching = false;
  bool _joining = false;
  Course? _found;
  String? _errorMsg;
  final List<Course> _joined = [];

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;

    final s = context.s;
    final code = _codeCtrl.text.trim();

    setState(() {
      _searching = true;
      _found = null;
      _errorMsg = null;
    });

    try {
      final course = await ApiService.findCourseByCode(code);

      if (!mounted) return;

      if (course == null) {
        setState(() => _errorMsg = '${s.notFound}: «$code»');
      } else if (_joined.any((c) => c.id == course.id)) {
        setState(() => _errorMsg = s.alreadyJoined);
      } else {
        setState(() => _found = course);
      }
    } catch (_) {
      if (mounted) setState(() => _errorMsg = s.notFound);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _join() async {
    if (_found == null) return;
    final s = context.s;

    setState(() => _joining = true);
    try {
      await ApiService.joinCourse(_found!.id);
      if (!mounted) return;

      setState(() {
        _joined.add(_found!);
        _found = null;
        _codeCtrl.clear();
        _errorMsg = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.joinedSuccess),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _continue() {
    if (widget.isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = context.s;

    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) => Scaffold(
        backgroundColor: c.bgSecondary,
        appBar: widget.isFirstTime
            ? null
            : AppBar(title: Text(s.joinTitle), leading: const BackButton()),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isFirstTime) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.joinTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.joinSub,
                      style: TextStyle(fontSize: 14, color: c.textSecondary),
                    ),
                    const SizedBox(height: 28),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      s.joinSub,
                      style: TextStyle(fontSize: 14, color: c.textSecondary),
                    ),
                    const SizedBox(height: 20),
                  ],

                  //поле ввода кода
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.bgPrimary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.border),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            s.courseCode,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _codeCtrl,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                    letterSpacing: 2,
                                  ),
                                  textInputAction: TextInputAction.search,
                                  onFieldSubmitted: (_) => _search(),
                                  decoration: InputDecoration(
                                    hintText: s.courseCodeHint,
                                    hintStyle: TextStyle(
                                      color: c.textTertiary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                    ),
                                    fillColor: c.bgTertiary,
                                    filled: true,
                                    prefixIcon: Icon(
                                      Icons.tag_rounded,
                                      size: 18,
                                      color: c.textTertiary,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: c.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppTheme.danger,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppTheme.danger,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? s.enterCode
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _searching ? null : _search,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: _searching
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(s.find),
                                ),
                              ),
                            ],
                          ),

                          //щшибка
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: c.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 16,
                                    color: AppTheme.danger,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMsg!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          //найденный курс
                          if (_found != null) ...[
                            const SizedBox(height: 16),
                            _FoundCourseCard(course: _found!),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _joining ? null : _join,
                                icon: _joining
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add_rounded, size: 18),
                                label: Text(s.join),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  //добавленные курсы
                  if (_joined.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      s.joinedCourses,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._joined.asMap().entries.map(
                      (e) => _JoinedTile(course: e.value, colorIndex: e.key),
                    ),
                  ],

                  const SizedBox(height: 32),

                  //кнопки внизу
                  if (widget.isFirstTime) ...[
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _joined.isEmpty ? null : _continue,
                        child: Text(s.continueBtn),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _continue,
                      child: Text(
                        s.skip,
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                      ),
                    ),
                  ] else if (_joined.isNotEmpty) ...[
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _continue,
                        child: Text(s.continueBtn),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoundCourseCard extends StatelessWidget {
  final Course course;
  const _FoundCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '${course.professor} • ${course.code}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _JoinedTile extends StatelessWidget {
  final Course course;
  final int colorIndex;
  const _JoinedTile({required this.course, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final iconColor = AppTheme
        .courseIconColors[colorIndex % AppTheme.courseIconColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              course.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              course.code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
