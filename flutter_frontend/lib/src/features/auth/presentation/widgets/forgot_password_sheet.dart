import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:validatorless/validatorless.dart';
import 'package:watt/src/services/toast_service.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final TextEditingController _emailController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.reset_password,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.reset_password_instructions,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validatorless.multiple([
                  Validatorless.required(
                    AppLocalizations.of(context)!.email_is_required,
                  ),
                  Validatorless.email(
                    AppLocalizations.of(context)!.invalid_email,
                  ),
                ]),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: RoundedLoadingButton(
                controller: _btnController,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await getIt<AuthRepository>().requestPasswordReset(
                        _emailController.text.trim(),
                      );
                      if (!context.mounted) return;
                      _btnController.success();
                      context.pop();
                      ToastService.success(
                        context,
                        AppLocalizations.of(context)!.success,
                        AppLocalizations.of(context)!.password_reset_email_sent,
                      );
                    } catch (e) {
                      _btnController.error();
                      await Future.delayed(const Duration(seconds: 1));
                      _btnController.reset();
                      if (context.mounted) {
                        ToastService.error(
                          context,
                          AppLocalizations.of(context)!.error,
                          e.toString(),
                        );
                      }
                    }
                  } else {
                    _btnController.error();
                    await Future.delayed(const Duration(seconds: 1));
                    _btnController.reset();
                  }
                },
                color: Theme.of(context).primaryColor,
                child: Text(
                  AppLocalizations.of(context)!.send_reset_link,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
