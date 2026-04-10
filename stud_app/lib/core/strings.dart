import 'package:flutter/material.dart';
import '../app.dart';

class AppStrings {
  final bool isRu;
  const AppStrings({required this.isRu});

  String get appName        => 'LearnHub';
  String get welcomeBack    => isRu ? 'Добро пожаловать' : 'Welcome back';
  String get email          => isRu ? 'Эл. почта' : 'Email';
  String get password       => isRu ? 'Пароль' : 'Password';
  String get login          => isRu ? 'Войти' : 'Login';
  String get createAccount  => isRu ? 'Создать аккаунт' : 'Create an account';
  String get loginError     => isRu ? 'Неверный email или пароль.' : 'Invalid email or password.';
  String get darkMode       => isRu ? 'Тёмная тема' : 'Dark mode';
  String get lightMode      => isRu ? 'Светлая тема' : 'Light mode';

  String get registerTitle  => isRu ? 'Создать аккаунт' : 'Create account';
  String get registerSub    => isRu ? 'Заполни данные для регистрации' : 'Fill in your details';
  String get iAm            => isRu ? 'Я' : 'I am a';
  String get student        => isRu ? 'Студент' : 'Student';
  String get teacher        => isRu ? 'Преподаватель' : 'Teacher';
  String get fullName       => isRu ? 'Полное имя' : 'Full name';
  String get fullNameHint   => isRu ? 'Алексей Иванов' : 'John Smith';
  String get confirmPass    => isRu ? 'Подтверди пароль' : 'Confirm password';
  String get repeatPass     => isRu ? 'Повтори пароль' : 'Repeat password';
  String get register       => isRu ? 'Зарегистрироваться' : 'Sign up';
  String get alreadyHave    => isRu ? 'Уже есть аккаунт?' : 'Already have an account?';
  String get signIn         => isRu ? 'Войти' : 'Sign in';
  String get minChars       => isRu ? 'Минимум 8 символов' : 'Minimum 8 characters';
  String get enterName      => isRu ? 'Введи имя' : 'Enter your name';
  String get enterFullName  => isRu ? 'Введи имя и фамилию' : 'Enter first and last name';
  String get enterEmail     => isRu ? 'Введи email' : 'Enter email';
  String get invalidEmail   => isRu ? 'Некорректный email' : 'Invalid email';
  String get enterPassword  => isRu ? 'Введи пароль' : 'Enter password';
  String get passMin8       => isRu ? 'Минимум 8 символов' : 'At least 8 characters';
  String get confirmPwd     => isRu ? 'Подтверди пароль' : 'Confirm password';
  String get passMismatch   => isRu ? 'Пароли не совпадают' : 'Passwords do not match';
  String get registerError  => isRu ? 'Не удалось создать аккаунт.' : 'Could not create account.';

  String get home           => isRu ? 'Главная' : 'Home';
  String get courses        => isRu ? 'Курсы' : 'Courses';
  String get profile        => isRu ? 'Профиль' : 'Profile';
  String get myCourses      => isRu ? 'Мои курсы' : 'My courses';
  String get greeting       => isRu ? 'Привет' : 'Hey';
  String get todaySummary   => isRu ? 'Вот сводка на сегодня' : 'Here\'s your summary';
  String get upcomingDead   => isRu ? 'Ближайшие дедлайны' : 'Upcoming deadlines';
  String get total          => isRu ? 'всего' : 'total';
  String get noDeadlines    => isRu ? 'Нет активных дедлайнов' : 'No active deadlines';
  String get allDone        => isRu ? 'Все задания сданы вовремя!' : 'All assignments on time!';
  String get coursesCount   => isRu ? 'Курсов' : 'Courses';
  String get assignmentsCount => isRu ? 'Заданий' : 'Assignments';
  String get overdueCount   => isRu ? 'Просрочено' : 'Overdue';
  String get today          => isRu ? 'Сегодня' : 'Today';
  String get inDays         => isRu ? 'дн.' : 'd.';
  String get inPrefix       => isRu ? 'Через' : 'In';
  String get overdue        => isRu ? 'Просрочено' : 'Overdue';
  String get members        => isRu ? 'участников' : 'members';

  String get createCourse    => isRu ? 'Создать курс' : 'Create course';
  String get newPost         => isRu ? 'Новая публикация' : 'New post';
  String get newAssignment   => isRu ? 'Задание' : 'Assignment';
  String get newAnnouncement => isRu ? 'Объявление' : 'Announcement';
  String get postTitle       => isRu ? 'Заголовок' : 'Title';
  String get postContent     => isRu ? 'Описание' : 'Description';
  String get deadline        => isRu ? 'Дедлайн' : 'Deadline';
  String get maxPoints       => isRu ? 'Баллы' : 'Points';
  String get publish         => isRu ? 'Опубликовать' : 'Publish';
  String get submissions     => isRu ? 'Работы' : 'Submissions';
  String get noSubmissions   => isRu ? 'Работ пока нет' : 'No submissions yet';
  String get gradeLabel      => isRu ? 'Оценка' : 'Grade';
  String get feedbackLabel   => isRu ? 'Комментарий' : 'Feedback';
  String get saveGrade       => isRu ? 'Сохранить оценку' : 'Save grade';
  String get myCourseCode    => isRu ? 'Код курса' : 'Course code';
  String get recentSubmissions => isRu ? 'Последние работы' : 'Recent submissions';
  String get totalStudents   => isRu ? 'Студентов' : 'Students';
  String get courseName      => isRu ? 'Название курса' : 'Course name';
  String get courseDesc      => isRu ? 'Описание' : 'Description';
  String get courseCreated   => isRu ? 'Курс создан!' : 'Course created!';
  String get pendingLabel    => isRu ? 'На проверке' : 'Pending';
  String get gradedLabel     => isRu ? 'Проверено' : 'Graded';

  String get feed           => isRu ? 'Лента' : 'Feed';
  String get membersTab     => isRu ? 'Участники' : 'Members';
  String get teacherLabel   => isRu ? 'Преподаватель' : 'Teacher';
  String get studentsLabel  => isRu ? 'Студенты' : 'Students';
  String get participants   => isRu ? 'участников' : 'participants';
  String get postedAgo      => isRu ? 'Опубликовано' : 'Posted';

  String get assignDetails  => isRu ? 'Детали задания' : 'Assignment Details';
  String get yourSubmit     => isRu ? 'Ваша работа' : 'Your submission';
  String get attachFile     => isRu ? 'Прикрепить файл...' : 'Attach a file...';
  String get privateComment => isRu ? 'Приватный комментарий (необяз.)' : 'Private comment (optional)...';
  String get submitBtn      => isRu ? 'Сдать задание' : 'Submit Assignment';
  String get submitted      => isRu ? 'Задание сдано!' : 'Assignment submitted!';
  String get classComments  => isRu ? 'Комментарии класса' : 'Class comments';
  String get noComments     => isRu ? 'Комментариев пока нет.' : 'No comments yet.';
  String get addComment     => isRu ? 'Добавить комментарий...' : 'Add a class comment...';
  String get dueLabel       => isRu ? 'Срок' : 'Due';
  String get points         => isRu ? 'баллов' : 'points';
  String get grade          => isRu ? 'Оценка' : 'Grade';

  String get joinTitle      => isRu ? 'Вступить в курс' : 'Join a course';
  String get joinSub        => isRu ? 'Введи код курса от преподавателя' : 'Enter the course code from your teacher';
  String get courseCode     => isRu ? 'Код курса' : 'Course code';
  String get courseCodeHint => isRu ? 'Например: CS101' : 'e.g. CS101';
  String get find           => isRu ? 'Найти' : 'Find';
  String get join           => isRu ? 'Вступить' : 'Join';
  String get joinedCourses  => isRu ? 'Добавленные курсы' : 'Joined courses';
  String get continueBtn    => isRu ? 'Продолжить' : 'Continue';
  String get skip           => isRu ? 'Пропустить' : 'Skip';
  String get notFound       => isRu ? 'Курс не найден' : 'Course not found';
  String get alreadyJoined  => isRu ? 'Вы уже в этом курсе' : 'Already joined';
  String get joinedSuccess  => isRu ? 'Вступили в курс!' : 'Joined successfully!';
  String get enterCode      => isRu ? 'Введи код' : 'Enter code';
  String get joinAnother    => isRu ? '+ Добавить ещё курс' : '+ Add another course';

  String get profileTitle   => isRu ? 'Профиль' : 'Profile';
  String get settings       => isRu ? 'Настройки' : 'Settings';
  String get settingsTitle  => isRu ? 'Настройки' : 'Settings';
  String get logout         => isRu ? 'Выйти' : 'Log out';
  String get appearance     => isRu ? 'Внешний вид' : 'Appearance';
  String get language       => isRu ? 'Язык' : 'Language';
  String get langRu         => isRu ? 'Русский' : 'Russian';
  String get langEn         => isRu ? 'Английский' : 'English';
  String get account        => isRu ? 'Аккаунт' : 'Account';
  String get notifications  => isRu ? 'Уведомления' : 'Notifications';
  String get notifSub       => isRu ? 'Дедлайны и новые посты' : 'Deadlines and new posts';
  String get saveChanges    => isRu ? 'Сохранить' : 'Save';
}

extension StringsExt on BuildContext {
  AppStrings get s => AppStrings(isRu: languageNotifier.isRu);
}