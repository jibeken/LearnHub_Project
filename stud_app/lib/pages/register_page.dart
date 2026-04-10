import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'join_course_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String _role = 'student';
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      //отправка запроса на сервер
      await ApiService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => _role == 'teacher'
              ? const HomePage()
              : const JoinCoursePage(isFirstTime: true),
        ),
        (route) =>
            false,
      );
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bgSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  //иконка
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
                    'Создать аккаунт',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Заполни данные для регистрации',
                    style: TextStyle(fontSize: 14, color: c.textSecondary),
                  ),
                  const SizedBox(height: 28),

                  //основная форма
                  Container(
                    padding: const EdgeInsets.all(24),
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
                          const _FieldLabel('Я'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _RoleButton(
                                  label: 'Студент',
                                  icon: Icons.school_outlined,
                                  selected: _role == 'student',
                                  onTap: () =>
                                      setState(() => _role = 'student'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RoleButton(
                                  label: 'Преподаватель',
                                  icon: Icons.person_outline_rounded,
                                  selected: _role == 'teacher',
                                  onTap: () =>
                                      setState(() => _role = 'teacher'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const _FieldLabel('Полное имя'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'Алексей Иванов',
                            icon: Icons.badge_outlined,
                            action: TextInputAction.next,
                            c: c,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty){
                                return 'Введи имя';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _emailCtrl,
                            hint: 'example@mail.com',
                            icon: Icons.mail_outline_rounded,
                            action: TextInputAction.next,
                            keyboard: TextInputType.emailAddress,
                            c: c,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Введи email';
                              if (!v.contains('@')) return 'Некорректный email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel('Пароль'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _passwordCtrl,
                            hint: 'Минимум 8 символов',
                            icon: Icons.lock_outline_rounded,
                            action: TextInputAction.next,
                            obscure: _obscurePassword,
                            c: c,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: c.textTertiary,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Введи пароль';
                              if (v.length < 8){
                                return 'Слишком короткий пароль';
                                }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel('Подтвердите пароль'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _confirmCtrl,
                            hint: 'Повторите пароль',
                            icon: Icons.lock_outline_rounded,
                            action: TextInputAction.done,
                            obscure: _obscureConfirm,
                            c: c,
                            onSubmitted: (_) => _register(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: c.textTertiary,
                              ),
                            ),
                            validator: (v) {
                              if (v != _passwordCtrl.text){
                                return 'Пароли не совпадают';
                                }
                              return null;
                            },
                          ),

                          //отображения ошибки от сервера
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: c.dangerLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.danger.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMsg!,
                                      style: const TextStyle(
                                        color: AppTheme.danger,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          //кнопка регистрации
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Зарегистрироваться',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Уже есть аккаунт?',
                        style: TextStyle(color: c.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Войти',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //вспомогательный метод для полей ввода
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputAction action,
    required ResolvedColors c,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
        fillColor: c.bgTertiary,
        filled: true,
        prefixIcon: Icon(icon, size: 20, color: c.textTertiary),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

//Студент/Учитель
class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.1) : c.bgTertiary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : c.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? AppTheme.primary : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}