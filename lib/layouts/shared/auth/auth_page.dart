import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:solar_hub/controllers/auth_controller.dart';
import 'package:solar_hub/layouts/shared/auth/widgets/forgot_password_sheet.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_hub/utils/toast_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late TabController _tabController;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final RoundedLoadingButtonController _loginBtnController = RoundedLoadingButtonController();

  // Sign Up Controllers
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpPhoneController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final RoundedLoadingButtonController _signUpBtnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primaryColor.withValues(alpha: 0.1)),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary.withValues(alpha: 0.1)),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(tag: 'logo', child: Image.asset('assets/png/logo.png', height: 80)).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                    const SizedBox(height: 30),

                    // Tab Bar
                    Container(
                      height: 55,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200], borderRadius: BorderRadius.circular(30)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: theme.primaryColor,
                          boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 30),

                    // Forms
                    SizedBox(
                      height: 480,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_buildLoginForm(theme), _buildSignUpForm(theme)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Get.offAllNamed('/home')),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildSocialLogin(theme),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _loginEmailController,
            label: 'Email',
            icon: Iconsax.sms_bold,
            validator: Validatorless.multiple([Validatorless.required('Email is required'), Validatorless.email('Invalid email')]),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Iconsax.lock_bold,
            isPassword: true,
            validator: Validatorless.required('Password is required'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  isScrollControlled: true,
                  builder: (context) => ForgotPasswordSheet(),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
          RoundedLoadingButton(
            controller: _loginBtnController,
            onPressed: _handleLogin,
            width: 200,
            color: theme.primaryColor,
            elevation: 0,
            borderRadius: 12,
            child: const Text(
              'LOGIN',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),
    );
  }

  Widget _buildSignUpForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            _buildSocialLogin(theme),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _signUpNameController,
              label: 'Full Name',
              icon: Iconsax.user_bold,
              validator: Validatorless.required('Name is required'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPhoneController,
              label: 'Phone Number',
              icon: Iconsax.call_bold,
              inputType: TextInputType.phone,
              validator: Validatorless.multiple([Validatorless.required('Phone is required'), Validatorless.number('Enter valid phone number')]),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpEmailController,
              label: 'Email',
              icon: Iconsax.sms_bold,
              validator: Validatorless.multiple([Validatorless.required('Email is required'), Validatorless.email('Invalid email')]),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPasswordController,
              label: 'Password',
              icon: Iconsax.lock_bold,
              isPassword: true,
              validator: Validatorless.multiple([Validatorless.required('Password is required'), Validatorless.min(6, 'Min 6 characters')]),
            ),
            const SizedBox(height: 30),
            RoundedLoadingButton(
              controller: _signUpBtnController,
              onPressed: _handleSignUp,
              width: 200,
              color: theme.primaryColor,
              elevation: 0,
              borderRadius: 12,
              child: const Text(
                'SIGN UP',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).moveX(begin: 20, end: 0),
      ),
    );
  }

  Widget _buildSocialLogin(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _socialButton(Brand(Brands.google, size: 24), "Google", () async {
          try {
            await _authController.signInWithGoogle();
          } catch (e) {
            _showMessage("Error", "Google Sign In Failed: $e", isError: true);
          }
        }),
        _socialButton(Brand(Brands.apple_logo, size: 24), "Apple", () async {
          try {
            await _authController.signInWithApple();
          } catch (e) {
            _showMessage("Error", "Apple Sign In Failed: $e", isError: true);
          }
        }),
      ],
    );
  }

  Widget _socialButton(Widget icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    if (isError) {
      ToastService.error(title, message);
    } else {
      ToastService.success(title, message);
    }
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        await _authController.signIn(_loginEmailController.text.trim(), _loginPasswordController.text);
        _loginBtnController.success();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/home');
      } catch (e) {
        _loginBtnController.error();
        _showMessage('Login Failed', e.toString(), isError: true);
        await Future.delayed(const Duration(seconds: 1));
        _loginBtnController.reset();
      }
    } else {
      _loginBtnController.error();
      await Future.delayed(const Duration(seconds: 1));
      _loginBtnController.reset();
    }
  }

  Future<void> _handleSignUp() async {
    if (_signUpFormKey.currentState!.validate()) {
      try {
        final data = {'full_name': _signUpNameController.text.trim(), 'phone_number': _signUpPhoneController.text.trim()};
        await _authController.signUp(_signUpEmailController.text.trim(), _signUpPasswordController.text, data);
        _signUpBtnController.success();
        _showMessage('Account Created', 'Please verify your email address.');
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/home');
      } catch (e) {
        _signUpBtnController.error();
        _showMessage('Sign Up Failed', e.toString(), isError: true);
        await Future.delayed(const Duration(seconds: 1));
        _signUpBtnController.reset();
      }
    } else {
      _signUpBtnController.error();
      await Future.delayed(const Duration(seconds: 1));
      _signUpBtnController.reset();
    }
  }
}
