import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_form_error_banner.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_image_picker.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:validatorless/validatorless.dart';

/// Create / edit company work form.
///
/// Supports both standalone (with scaffold) and embedded (inside dashboard shell)
/// modes.
class CompanyWorkFormPage extends ConsumerStatefulWidget {
  final bool embedded;
  final CompanyWork? work;

  const CompanyWorkFormPage({
    super.key,
    this.embedded = false,
    this.work,
  });

  @override
  ConsumerState<CompanyWorkFormPage> createState() => _CompanyWorkFormPageState();
}

class _CompanyWorkFormPageState extends ConsumerState<CompanyWorkFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyWorkFormNotifierProvider.notifier).initialize(widget.work);
      if (widget.work != null) {
        _titleController.text = widget.work!.title;
        _bodyController.text = widget.work!.body ?? '';
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.work != null;
    final state = ref.watch(companyWorkFormNotifierProvider);

    final formContent = SingleChildScrollView(
      padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.error != null) ...[
                  CompanyWorkFormErrorBanner(message: state.error!),
                  const SizedBox(height: 16),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.basicInformation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ref.watch(appColorsProvider).textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _titleController,
                        label: l10n.company_work_title_field,
                        prefixIcon: Iconsax.text,
                        validator: Validatorless.required(l10n.company_work_title_required),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _bodyController,
                        label: l10n.company_work_body_field,
                        prefixIcon: Iconsax.document_text,
                        minLines: 5,
                        maxLines: 10,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.company_work_images,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ref.watch(appColorsProvider).textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CompanyWorkImagePicker(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: isEditing
                      ? l10n.company_work_save_changes
                      : l10n.company_work_publish,
                  icon: isEditing ? Iconsax.edit_2 : Iconsax.add_circle,
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return formContent;
    }

    return BaseScreen(
      title: isEditing ? l10n.company_work_edit_title : l10n.company_work_add_title,
      child: formContent,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(companyWorkFormNotifierProvider.notifier).saveWork(
          workId: widget.work?.id,
          title: _titleController.text,
          body: _bodyController.text,
        );

    if (!mounted || !success) return;
    final l10n = AppLocalizations.of(context)!;
    ToastService.success(
      context,
      l10n.success,
      widget.work == null ? l10n.company_work_created : l10n.company_work_updated,
    );
    context.pop();
  }
}
