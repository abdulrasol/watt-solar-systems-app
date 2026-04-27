import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_image_picker.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyWorkFormPage extends ConsumerStatefulWidget {
  const CompanyWorkFormPage({super.key, this.work});

  final CompanyWork? work;

  @override
  ConsumerState<CompanyWorkFormPage> createState() =>
      _CompanyWorkFormPageState();
}

class _CompanyWorkFormPageState extends ConsumerState<CompanyWorkFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(companyWorkFormNotifierProvider.notifier)
          .initialize(widget.work);
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

    return PreScaffold(
      title: isEditing
          ? l10n.company_work_edit_title
          : l10n.company_work_add_title,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (state.error != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _SectionCard(
                title: l10n.basicInformation,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.company_work_title_field,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      validator: Validatorless.required(
                        l10n.company_work_title_required,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _bodyController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: l10n.company_work_body_field,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              _SectionCard(
                title: l10n.company_work_images,
                child: const CompanyWorkImagePicker(),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditing
                              ? l10n.company_work_save_changes
                              : l10n.company_work_publish,
                        ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(companyWorkFormNotifierProvider.notifier)
        .saveWork(
          workId: widget.work?.id,
          title: _titleController.text,
          body: _bodyController.text,
        );

    if (!mounted || !success) return;
    final l10n = AppLocalizations.of(context)!;
    ToastService.success(
      context,
      l10n.success,
      widget.work == null
          ? l10n.company_work_created
          : l10n.company_work_updated,
    );
    context.pop();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}
