import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_button.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

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
          isArabic ? 'لوحة الطالب' : 'Student Dashboard',
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
                    isArabic ? 'مرحباً، أحمد!' : 'Welcome, Student!',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'لديك 2 درس جديد واختبار في انتظارك'
                        : 'You have 2 new lessons and a quiz awaiting you',
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
                    title: isArabic ? 'الدروس' : 'Lessons',
                    value: '15',
                    icon: Icons.book,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'الاختبارات' : 'Quizzes',
                    value: '5',
                    icon: Icons.quiz,
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
                    title: isArabic ? 'التقدم' : 'Progress',
                    value: '75%',
                    icon: Icons.trending_up,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: isArabic ? 'الشهادات' : 'Certificates',
                    value: '3',
                    icon: Icons.card_membership,
                    color: Colors.purple,
                  ),
                ),
              ],
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
                _buildActionCard(
                  title: isArabic ? 'عرض الدروس' : 'View Lessons',
                  icon: Icons.book,
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/lessons'),
                ),
                _buildActionCard(
                  title: isArabic ? 'حل الاختبارات' : 'Take Quizzes',
                  icon: Icons.quiz,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/quizzes'),
                ),
                _buildActionCard(
                  title: isArabic ? 'المواد' : 'Materials',
                  icon: Icons.folder,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/materials'),
                ),
                _buildActionCard(
                  title: isArabic ? 'التقدم' : 'Track Progress',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/progress'),
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
                          ? (isArabic ? 'أكملت درس الجبر' : 'Completed Algebra lesson')
                          : index == 1
                          ? (isArabic ? 'حللت اختبار الهندسة' : 'Took Geometry quiz')
                          : (isArabic ? 'حصلت على شهادة' : 'Earned a certificate'),
                      index == 0 ? '2 ساعات' : index == 1 ? '4 ساعات' : '6 ساعات',
                      index == 0 ? '2 hours ago' : index == 1 ? '4 hours ago' : '6 hours ago',
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

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
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