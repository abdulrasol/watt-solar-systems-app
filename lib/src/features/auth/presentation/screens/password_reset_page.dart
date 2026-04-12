import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:validatorless/validatorless.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  bool _isTokenVerified = false;
  bool _isValidatingToken = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateToken({bool showSuccess = true}) async {
    final l10n = AppLocalizations.of(context)!;
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ToastService.error(context, l10n.error, l10n.reset_token_required);
      return;
    }

    setState(() {
      _isValidatingToken = true;
    });
    try {
      await getIt<AuthRepository>().validatePasswordResetToken(token);
      if (!mounted) return;
      setState(() {
        _isTokenVerified = true;
      });
      if (showSuccess) {
        ToastService.success(context, l10n.success, l10n.reset_token_verified);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTokenVerified = false;
      });
      ToastService.error(context, l10n.error, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingToken = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      _submitController.error();
      await Future.delayed(const Duration(seconds: 1));
      _submitController.reset();
      return;
    }

    try {
      if (!_isTokenVerified) {
        await _validateToken(showSuccess: false);
        if (!_isTokenVerified) {
          _submitController.error();
          await Future.delayed(const Duration(seconds: 1));
          _submitController.reset();
          return;
        }
      }

      await getIt<AuthRepository>().confirmPasswordReset(
        token: _tokenController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _submitController.success();
      ToastService.success(context, l10n.success, l10n.password_reset_success);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        context.go('/auth');
      }
    } catch (e) {
      if (!mounted) return;
      _submitController.error();
      ToastService.error(context, l10n.error, e.toString());
      await Future.delayed(const Duration(seconds: 1));
      _submitController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reset_password)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.reset_password_token_instructions,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: l10n.reset_token,
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: _isTokenVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) {
                    if (_isTokenVerified) {
                      setState(() {
                        _isTokenVerified = false;
                      });
                    }
                  },
                  validator: Validatorless.required(l10n.reset_token_required),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isValidatingToken ? null : _validateToken,
                  icon: _isValidatingToken
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(l10n.verify_token),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.new_password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: Validatorless.multiple([
                    Validatorless.required(l10n.password_is_required),
                    Validatorless.min(6, l10n.min_6_characters),
                  ]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirm_new_password,
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: Validatorless.multiple([
                    Validatorless.required(l10n.confirm_password_is_required),
                    (value) => value != _passwordController.text
                        ? l10n.passwords_do_not_match
                        : null,
                  ]),
                ),
                const SizedBox(height: 28),
                RoundedLoadingButton(
                  controller: _submitController,
                  onPressed: _submit,
                  color: theme.primaryColor,
                  borderRadius: 12,
                  child: Text(
                    l10n.reset_password,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
