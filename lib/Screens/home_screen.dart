import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/language_selector.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _lessons = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
      return;
    }
    await _fetchLessons(authProvider.isTeacher ? UserRole.teacher : UserRole.student);
  }

  Future<void> _fetchLessons(UserRole role) async {
    setState(() {
      _lessons = [];
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (role == UserRole.teacher) {
        _lessons = await FirebaseService.getLessonsByTeacher(authProvider.user!.uid);
      } else {
        final enrolledLessonIds = await FirebaseService.getEnrolledLessons(authProvider.user!.uid);
        final allLessons = await FirebaseService.getLessons();
        _lessons = allLessons
            .where((lesson) => !enrolledLessonIds.contains(lesson['id']))
            .toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).isArabic
                  ? 'خطأ في جلب الدروس'
                  : 'Error fetching lessons',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await authProvider.signOut();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                                (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(229),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.logout,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                    ),
                    const LanguageSelector(),
                  ],
                ),
                const SizedBox(height: 40),
                // Welcome Message
                Text(
                  authProvider.userModel != null
                      ? (isArabic
                      ? 'مرحباً ${authProvider.userModel!.fullName ?? authProvider.userModel!.email}!'
                      : 'Welcome ${authProvider.userModel!.fullName ?? authProvider.userModel!.email}!')
                      : (isArabic ? 'مرحباً!' : 'Welcome!'),
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 32,
                    color: AppColors.highContrastText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.isTeacher
                      ? (isArabic
                      ? 'إدارة دروسك هنا'
                      : 'Manage your lessons here')
                      : (isArabic
                      ? 'استكشف دروسك'
                      : 'Explore your lessons'),
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Action Button for Teachers
                if (authProvider.isTeacher)
                  CustomButton(
                    text: isArabic ? 'إنشاء درس جديد' : 'Create New Lesson',
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic
                                ? 'سيتم إضافة إنشاء الدرس قريباً'
                                : 'Lesson creation coming soon'),
                          ),
                        );
                      }
                    },
                    height: 60,
                    width: 250,
                  ),
                const SizedBox(height: 20),
                // Lessons List
                Expanded(
                  child: _lessons.isEmpty
                      ? Center(
                    child: Text(
                      isArabic
                          ? 'لا توجد دروس متاحة'
                          : 'No lessons available',
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return _buildLessonCard(
                        context,
                        lesson['title'] ?? 'Lesson ${index + 1}',
                        lesson['description'] ?? '',
                        authProvider.isTeacher,
                        isArabic,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(
      BuildContext context,
      String title,
      String description,
      bool isTeacher,
      bool isArabic,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.body1.copyWith(fontSize: 14, color: Colors.black54),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isTeacher
            ? IconButton(
          icon: const Icon(Icons.edit, color: AppColors.primary),
          onPressed: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic
                      ? 'سيتم إضافة تعديل الدرس قريباً'
                      : 'Lesson editing coming soon'),
                ),
              );
            }
          },
        )
            : CustomButton(
          text: isArabic ? 'التسجيل' : 'Enroll',
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            try {
              final lessonId = _lessons.firstWhere((l) => l['title'] == title)['id'];
              await FirebaseService.enrollStudent(
                authProvider.user!.uid,
                lessonId,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic
                        ? 'تم التسجيل في الدرس'
                        : 'Enrolled in lesson'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _fetchLessons(UserRole.student);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic
                        ? 'خطأ في التسجيل'
                        : 'Error enrolling in lesson'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          width: 100,
          height: 40,
        ),
      ),
    );
  }
}