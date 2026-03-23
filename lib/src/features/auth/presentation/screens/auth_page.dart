import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/user_register_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/forgot_password_sheet.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_hub/src/utils/toast_service.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Login Controllers
  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final RoundedLoadingButtonController _loginBtnController =
      RoundedLoadingButtonController();

  // Sign Up Controllers
  final TextEditingController _signUpFirstNameController =
      TextEditingController();
  final TextEditingController _signUpLastNameController =
      TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpUsernameController =
      TextEditingController();
  final TextEditingController _signUpPhoneController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  final TextEditingController _signUpConfirmPasswordController =
      TextEditingController();
  final RoundedLoadingButtonController _signUpBtnController =
      RoundedLoadingButtonController();

  City? _selectedCity;
  Country? _selectedCountry;

  List<Country> _countries = [];
  List<City> _cities = [];
  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCountries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _signUpFirstNameController.dispose();
    _signUpLastNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpUsernameController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset('assets/png/logo.png', height: 80),
                    ).animate().scale(
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.welcome_back,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                    const SizedBox(height: 30),

                    // Tab Bar
                    Container(
                      height: 55,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: theme.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(text: l10n.login),
                          Tab(text: l10n.sign_up),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 30),

                    // Forms
                    SizedBox(
                      height: 750,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLoginForm(theme),
                          _buildSignUpForm(theme),
                        ],
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
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.go('/home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  l10n.or_text,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _loginUsernameController,
            label: AppLocalizations.of(context)!.username,
            icon: Iconsax.user_cirlce_add_bold,
            validator: Validatorless.multiple([
              Validatorless.required(
                AppLocalizations.of(context)!.username_is_required,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: AppLocalizations.of(context)!.password,
            icon: Iconsax.lock_bold,
            isPassword: true,
            validator: Validatorless.multiple([
              Validatorless.required(
                AppLocalizations.of(context)!.password_is_required,
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  builder: (context) => ForgotPasswordSheet(),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.forgot_password,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
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
            child: Text(
              AppLocalizations.of(context)!.login,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),
    );
  }

  Widget _buildSignUpForm(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildTextField(
              controller: _signUpFirstNameController,
              label: AppLocalizations.of(context)!.first_name,
              icon: Iconsax.user_bold,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpLastNameController,
              label: AppLocalizations.of(context)!.last_name,
              icon: Iconsax.user_bold,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpUsernameController,
              label: AppLocalizations.of(context)!.username,
              icon: Iconsax.user_cirlce_add_bold,
              validator: Validatorless.required(
                AppLocalizations.of(context)!.username_is_required,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpEmailController,
              label: AppLocalizations.of(context)!.email,
              icon: Iconsax.sms_bold,
              validator: Validatorless.email(
                AppLocalizations.of(context)!.invalid_email,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPhoneController,
              label: l10n.phone_number,
              icon: Iconsax.call_bold,
              inputType: TextInputType.phone,
              validator: Validatorless.multiple([
                Validatorless.required(l10n.phone_required),
                Validatorless.number(l10n.invalid_phone_number),
              ]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Country>(
                    initialValue: _selectedCountry,
                    decoration: InputDecoration(
                      labelText: _isLoadingCountries
                          ? AppLocalizations.of(context)!.loading
                          : AppLocalizations.of(context)!.country,
                      prefixIcon: _selectedCountry != null
                          ? Icon(Iconsax.location_bold, size: 20.r)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                    ),
                    items: _countries
                        .map(
                          (country) => DropdownMenuItem(
                            value: country,
                            child: Text(country.name),
                          ),
                        )
                        .toList(), // Now empty list
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        _selectedCity =
                            null; // Reset city to resolve assertion error
                        _fetchCities();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<City>(
                    initialValue: _selectedCity,
                    decoration: InputDecoration(
                      labelText: _isLoadingCities
                          ? AppLocalizations.of(context)!.loading
                          : AppLocalizations.of(context)!.city,
                      prefixIcon: _selectedCity != null
                          ? Icon(Iconsax.location_bold, size: 20.r)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                    ),
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city,
                            child: Text(city.name),
                          ),
                        )
                        .toList(), // Now empty list
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context)!.city_is_required;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPasswordController,
              label: AppLocalizations.of(context)!.password,
              icon: Iconsax.lock_bold,
              isPassword: true,
              validator: Validatorless.multiple([
                Validatorless.required(
                  AppLocalizations.of(context)!.password_is_required,
                ),
                Validatorless.min(6, l10n.min_6_characters),
              ]),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpConfirmPasswordController,
              label: AppLocalizations.of(context)!.confirm_password,
              icon: Iconsax.lock_bold,
              isPassword: true,
              validator: Validatorless.multiple([
                Validatorless.required(
                  AppLocalizations.of(context)!.confirm_password_is_required,
                ),
                (val) => val != _signUpPasswordController.text
                    ? AppLocalizations.of(context)!.passwords_do_not_match
                    : null,
              ]),
            ),
            const SizedBox(height: 30),
            RoundedLoadingButton(
              controller: _signUpBtnController,
              onPressed: _handleSignUp,
              width: 200,
              color: theme.primaryColor,
              elevation: 0,
              borderRadius: 12,
              child: Text(
                l10n.sign_up,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).moveX(begin: 20, end: 0),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    if (isError) {
      ToastService.error(context, title, message);
    } else {
      ToastService.success(context, title, message);
    }
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCountries();
      setState(() {
        _countries = response;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        AppLocalizations.of(context)!.error,
        e.toString(),
        isError: true,
      );
    }
    setState(() {
      _isLoadingCountries = false;
    });
  }

  Future<void> _fetchCities() async {
    if (_selectedCountry == null) return;
    setState(() {
      _isLoadingCities = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCities(
        countryId: _selectedCountry!.id,
      );
      setState(() {
        _cities = response;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        AppLocalizations.of(context)!.error,
        e.toString(),
        isError: true,
      );
    }
    setState(() {
      _isLoadingCities = false;
    });
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        final response = await getIt.get<AuthRepository>().login(
          _loginUsernameController.text.trim(),
          _loginPasswordController.text,
        );
        if (!mounted) return;
        ref.read(authProvider.notifier).login(response);
        _loginBtnController.success();
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go('/home');
      } catch (e) {
        if (!mounted) return;
        _loginBtnController.error();
        _showMessage(
          AppLocalizations.of(context)!.error,
          e.toString(),
          isError: true,
        );
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
        final response = await getIt.get<AuthRepository>().register(
          UserRegisterModel(
            username: _signUpUsernameController.text.trim(),
            password: _signUpPasswordController.text,
            firstName: _signUpFirstNameController.text.trim(),
            lastName: _signUpLastNameController.text.trim(),
            email: _signUpEmailController.text.trim(),
            phone: _signUpPhoneController.text.trim(),
            city: _selectedCity?.id,
          ),
        );
        if (!mounted) return;
        ref.read(authProvider.notifier).register(response);
        _signUpBtnController.success();
        _showMessage(
          AppLocalizations.of(context)!.account_created,
          AppLocalizations.of(context)!.please_verify_email,
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/home');
      } catch (e) {
        if (!mounted) return;
        _signUpBtnController.error();
        _showMessage(
          AppLocalizations.of(context)!.sign_up_failed,
          e.toString(),
          isError: true,
        );
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
