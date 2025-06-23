import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/language_selector.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isArabic = languageProvider.isArabic;

    final UserRole? selectedRole = ModalRoute.of(context)?.settings.arguments as UserRole?;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(76),
                  Colors.black.withAlpha(153),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(229),
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
                      const SizedBox(height: 40),
                      Text(
                        isArabic ? 'إنشاء حساب جديد' : 'Create Account',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 32,
                          color: AppColors.highContrastText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedRole != null
                            ? (selectedRole == UserRole.teacher
                            ? (isArabic ? 'انضم كمعلم' : 'Join as a Teacher')
                            : (isArabic ? 'انضم كطالب' : 'Join as a Student'))
                            : (isArabic ? 'انضم إلينا اليوم' : 'Join us today'),
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.white.withAlpha(179),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        label: isArabic ? 'الاسم الكامل' : 'Full Name',
                        hint: isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name',
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline,
                        validator: _validateFullName,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: isArabic ? 'البريد الإلكتروني' : 'Email',
                        hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: isArabic ? 'كلمة المرور' : 'Password',
                        hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                        hint: isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: isArabic ? 'إنشاء حساب' : 'Sign Up',
                        onPressed: authProvider.isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _handleSignUp(selectedRole);
                          }
                        },
                        height: 60,
                        enabled: !authProvider.isLoading,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              isArabic ? 'أو' : 'OR',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: isArabic ? 'إنشاء حساب بجوجل' : 'Sign up with Google',
                        onPressed: authProvider.isLoading
                            ? null
                            : () {
                          _handleGoogleSignUp();
                        },
                        isSecondary: true,
                        height: 60,
                        enabled: !authProvider.isLoading,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isArabic ? 'لديك حساب بالفعل؟ ' : "Already have an account? ",
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white.withAlpha(179),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              isArabic ? 'تسجيل الدخول' : 'Login',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (authProvider.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateFullName(String? value) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    if (value == null || value.isEmpty) {
      return isArabic ? 'الاسم مطلوب' : 'Name is required';
    }

    if (value.length < 2) {
      return isArabic
          ? 'الاسم يجب أن يكون حرفين على الأقل'
          : 'Name must be at least 2 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    if (value == null || value.isEmpty) {
      return isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required';
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return isArabic
          ? 'البريد الإلكتروني غير صحيح'
          : 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    if (value == null || value.isEmpty) {
      return isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
    }

    if (value.length < 6) {
      return isArabic
          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
          : 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    if (value == null || value.isEmpty) {
      return isArabic
          ? 'تأكيد كلمة المرور مطلوب'
          : 'Confirm password is required';
    }

    if (value != _passwordController.text) {
      return isArabic
          ? 'كلمات المرور غير متطابقة'
          : 'Passwords do not match';
    }

    return null;
  }

  Future<void> _handleSignUp(UserRole? selectedRole) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      role: selectedRole ?? UserRole.student,
    );

    if (success && mounted && authProvider.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted && authProvider.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }
  }
}