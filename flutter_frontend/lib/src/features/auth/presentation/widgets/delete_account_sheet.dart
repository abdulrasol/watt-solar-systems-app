import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:validatorless/validatorless.dart';

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final RoundedLoadingButtonController _deleteController = RoundedLoadingButtonController();

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final successTitle = l10n.success;
    final successMessage = l10n.account_deleted_successfully;
    final errorTitle = l10n.error;
    if (!_formKey.currentState!.validate()) {
      _deleteController.error();
      await Future.delayed(const Duration(seconds: 1));
      _deleteController.reset();
      return;
    }

    try {
      await getIt<AuthRepository>().deleteAccount(password: _passwordController.text, reason: _reasonController.text);
      await ref.read(authProvider.notifier).logout();
      _deleteController.success();
      final rootContext = rootNavigatorKey.currentContext;
      final rootNavigator = rootNavigatorKey.currentState;
      rootNavigator?.pop();
      if (rootContext != null) {
        // ignore: use_build_context_synchronously
        ToastService.success(rootContext, successTitle, successMessage);
        // ignore: use_build_context_synchronously
        GoRouter.of(rootContext).go('/home');
      }
    } catch (e) {
      _deleteController.error();
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        // ignore: use_build_context_synchronously
        ToastService.error(rootContext, errorTitle, e.toString());
      }
      await Future.delayed(const Duration(seconds: 1));
      _deleteController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.delete_account, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.delete_account_warning, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: Validatorless.required(l10n.password_is_required),
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.delete_account_reason,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_outlined)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _deleteController,
                  onPressed: _deleteAccount,
                  color: Colors.red,
                  borderRadius: 12,
                  child: Text(
                    l10n.delete_account,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
