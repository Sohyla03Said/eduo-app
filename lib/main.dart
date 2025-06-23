import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import your Firebase options
import 'firebase_options.dart';

// Import providers
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';

// Import models
import 'models/user_model.dart';

// Import screens
import 'screens/welcome_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/welcome.dart';
import 'screens/login_page.dart'; // Updated import
import 'screens/signup_page.dart';
import 'screens/home_screen.dart';

// Import student screens
import 'screens/student/student_dashboard.dart';

// Import teacher screens
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/teacher/lessons_management.dart';
import 'screens/teacher/materials_upload.dart';
import 'screens/teacher/quiz_creation.dart';
import 'screens/teacher/student_progress.dart';
import 'screens/teacher/assessments.dart';

// Import utils
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Learning App',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              fontFamily: languageProvider.isArabic ? 'Cairo' : 'Roboto',
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/welcome': (context) => const WelcomeScreen(),
              '/role-selection': (context) => const RoleSelectionScreen(),
              '/welcome-page': (context) => const WelcomePage(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/home': (context) => const HomeScreen(),
              '/assessments': (context) => const Assessments(),
              '/student-dashboard': (context) => const StudentDashboard(),
              '/teacher-dashboard': (context) => const TeacherDashboard(),
              '/lessons-management': (context) => const LessonsManagement(),
              '/materials-upload': (context) => const MaterialsUpload(),
              '/quiz-creation': (context) => const QuizCreation(),
              '/student-progress': (context) => const StudentProgress(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (context) => const WelcomeScreen());
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      final String? userRole = authProvider.userRole;
      if (userRole == 'student') return const StudentDashboard();
      if (userRole == 'teacher') return const TeacherDashboard();
      return const HomeScreen(); // Fallback
    }

    return const WelcomeScreen();
  }
}

// Error handling widget
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}