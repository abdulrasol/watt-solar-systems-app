import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/feedback/presentation/controllers/feedback_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:toastification/toastification.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (state.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          type: ToastificationType.success,
          title: Text(l10n.success),
          description: Text(_resolveSuccessMessage(l10n, state)),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        ref.read(feedbackProvider.notifier).clearSuccess();
        context.pop();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.send_feedback), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(context, isDark),
                const SizedBox(height: 24),
                _buildNameField(context),
                const SizedBox(height: 16),
                _buildPhoneField(context),
                const SizedBox(height: 16),
                _buildMessageField(context),
                const SizedBox(height: 16),
                _buildImageSection(context, state, isDark),
                const SizedBox(height: 24),
                _buildSubmitButton(context, state),
                if (state.error != null || state.errorCode != null) ...[const SizedBox(height: 16), _buildErrorCard(context, state)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(Iconsax.message_text_bold, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.feedback_info_title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.feedback_info_description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.name,
        hintText: AppLocalizations.of(context)!.name_hint,
        prefixIcon: const Icon(Iconsax.user_bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.name_required;
        }
        return null;
      },
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.phone_number,
        hintText: AppLocalizations.of(context)!.phone_hint,
        prefixIcon: const Icon(Iconsax.call_calling_bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1);
  }

  Widget _buildMessageField(BuildContext context) {
    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.message,
        hintText: AppLocalizations.of(context)!.feedback_hint,
        prefixIcon: const Icon(Iconsax.message_text_1_bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      maxLines: 5,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.feedback_required;
        }
        return null;
      },
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildImageSection(BuildContext context, FeedbackState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.add_screenshot, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            if (state.selectedImage != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    ref.read(feedbackProvider.notifier).removeImage();
                    _formKey.currentState?.reset();
                  });
                },
                icon: const Icon(Iconsax.trade_bold, size: 18),
                label: Text(AppLocalizations.of(context)!.remove),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: state.selectedImage == null ? () => ref.read(feedbackProvider.notifier).pickImage() : null,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: state.selectedImage != null ? AppTheme.primaryColor : Colors.grey.shade300, width: 2, style: BorderStyle.solid),
            ),
            child: state.selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.gallery_add_bold, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.tap_to_select_image, style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(state.selectedImage!, fit: BoxFit.cover),
                  ),
          ),
        ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, FeedbackState state) {
    return ElevatedButton(
      onPressed: state.isLoading
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                ref
                    .read(feedbackProvider.notifier)
                    .submitFeedback(
                      name: _nameController.text,
                      phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
                      message: _messageController.text,
                    );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: state.isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Icon(Iconsax.send_2_bold, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.send_feedback)],
            ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  String _resolveSuccessMessage(AppLocalizations l10n, FeedbackState state) {
    switch (state.successCode) {
      case 'feedback_submitted_successfully':
        return l10n.feedback_submitted_successfully;
      default:
        return l10n.feedback_submitted_successfully;
    }
  }

  Widget _buildErrorCard(BuildContext context, FeedbackState state) {
    final l10n = AppLocalizations.of(context)!;
    final error = _resolveErrorMessage(l10n, state);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle_bold, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }

  String _resolveErrorMessage(AppLocalizations l10n, FeedbackState state) {
    switch (state.errorCode) {
      case 'name_required':
        return l10n.name_required;
      case 'feedback_required':
        return l10n.feedback_required;
      case 'failed_to_pick_image':
        return l10n.failed_to_pick_image(state.errorDetail ?? '');
      default:
        return state.error ?? '';
    }
  }
}
