import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/teacher/dashboard_card.dart';
import '../../widgets/teacher/quick_actions.dart';
import '../../widgets/teacher/progress_chart.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          isArabic ? 'لوحة المعلم' : 'Teacher Dashboard',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'مرحباً بك، أستاذ أحمد' : 'Welcome back, Teacher!',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'لديك 3 مهام جديدة و 12 طالب في انتظار التقييم'
                        : 'You have 3 new tasks and 12 students awaiting assessment',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'الطلاب' : 'Students',
                    value: '124',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'الدروس' : 'Lessons',
                    value: '28',
                    icon: Icons.book,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'الاختبارات' : 'Quizzes',
                    value: '15',
                    icon: Icons.quiz,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'المواد' : 'Materials',
                    value: '42',
                    icon: Icons.folder,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'إحصائيات الأسبوع' : 'Weekly Analytics',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ProgressChart(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              isArabic ? 'الإجراءات السريعة' : 'Quick Actions',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: isArabic ? 'إنشاء درس' : 'Create Lesson',
                  icon: Icons.add_circle,
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/lessons-management'),
                ),
                DashboardCard(
                  title: isArabic ? 'متابعة الطلاب' : 'Track Students',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/student-progress'),
                ),
                DashboardCard(
                  title: isArabic ? 'رفع المواد' : 'Upload Materials',
                  icon: Icons.cloud_upload,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/materials-upload'),
                ),
                DashboardCard(
                  title: isArabic ? 'تقييم الطلاب' : 'Assess Students',
                  icon: Icons.assessment,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/assessments'),
                ),
                DashboardCard(
                  title: isArabic ? 'إنشاء اختبار' : 'Create Quiz',
                  icon: Icons.quiz,
                  color: Colors.red,
                  onTap: () => Navigator.pushNamed(context, '/quiz-creation'),
                ),
                DashboardCard(
                  title: isArabic ? 'التقارير' : 'Reports',
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/reports'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activities
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'الأنشطة الأخيرة' : 'Recent Activities',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                        (index) => _buildActivityItem(
                      isArabic,
                      index == 0
                          ? (isArabic ? 'أحمد محمد أكمل الاختبار' : 'Ahmed Mohamed completed quiz')
                          : index == 1
                          ? (isArabic ? 'تم رفع مادة جديدة' : 'New material uploaded')
                          : (isArabic ? 'فاطمة علي طلبت مساعدة' : 'Fatma Ali requested help'),
                      index == 0 ? '2 ساعات' : index == 1 ? '4 ساعات' : '6 ساعات',
                      isArabic ? '2 hours ago' : index == 1 ? '4 hours ago' : '6 hours ago',
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(bool isArabic, String activity, String timeAr, String timeEn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: AppTextStyles.body1,
                ),
                Text(
                  isArabic ? timeAr : timeEn,
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}