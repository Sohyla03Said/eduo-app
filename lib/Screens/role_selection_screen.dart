import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/language_selector.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Language Selector at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isArabic ? Icons.arrow_forward : Icons.arrow_back,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const LanguageSelector(),
                    ],
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          isArabic ? 'اختر دورك' : 'Select Your Role',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 36,
                            color: AppColors.highContrastText,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 60),

                        // Role Selection Cards
                        _buildRoleCard(
                          role: UserRole.teacher,
                          title: isArabic ? 'معلم' : 'Teacher',
                          subtitle: isArabic
                              ? 'قم بإنشاء وإدارة الدروس والطلاب'
                              : 'Create and manage lessons and students',
                          imagePath: 'assets/images/teacher.png',
                          isSelected: _selectedRole == UserRole.teacher,
                        ),

                        const SizedBox(height: 24),

                        _buildRoleCard(
                          role: UserRole.student,
                          title: isArabic ? 'طالب' : 'Student',
                          subtitle: isArabic
                              ? 'تعلم واكتشف دروس جديدة'
                              : 'Learn and discover new lessons',
                          imagePath: 'assets/images/student.png',
                          isSelected: _selectedRole == UserRole.student,
                        ),

                        const SizedBox(height: 60),

                        // Continue Button
                        CustomButton(
                          text: isArabic ? 'متابعة' : 'Continue',
                          onPressed: _selectedRole != null ? _handleContinue : () {},
                          height: 60,
                          width: 250,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isSelected ? 0.95 : 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: isSelected ? AppColors.primary : AppColors.highContrastText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.body1.copyWith(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedRole != null) {
      Navigator.pushNamed(
        context,
        '/welcome-page',
        arguments: _selectedRole,
      );
    }
  }
}