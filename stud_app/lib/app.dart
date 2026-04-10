import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'pages/login_page.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

class LanguageNotifier extends ChangeNotifier {
  bool _isRu = true;
  bool get isRu => _isRu;

  void setRussian() {
    _isRu = true;
    notifyListeners();
  }

  void setEnglish() {
    _isRu = false;
    notifyListeners();
  }

  void toggle() {
    _isRu = !_isRu;
    notifyListeners();
  }
}

final languageNotifier = LanguageNotifier();

class LearnHubApp extends StatefulWidget {
  const LearnHubApp({super.key});
  @override
  State<LearnHubApp> createState() => _LearnHubAppState();
}

class _LearnHubAppState extends State<LearnHubApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
    languageNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    languageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.mode,
      home: const LoginPage(),
    );
  }
}
