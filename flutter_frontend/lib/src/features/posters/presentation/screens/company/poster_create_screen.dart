import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/posters/data/data_sources/poster_remote_data_source.dart';
import 'package:solar_hub/src/features/posters/presentation/controllers/company_posters_provider.dart';
import 'package:solar_hub/src/features/posters/presentation/widgets/entity_picker_sheet.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class PosterCreateScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const PosterCreateScreen({super.key, this.embedded = false});

  @override
  ConsumerState<PosterCreateScreen> createState() => _PosterCreateScreenState();
}

class _PosterCreateScreenState extends ConsumerState<PosterCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String _actionType = 'product';
  int? _selectedActionId;
  String? _selectedActionName;
  String? _imagePath;
  bool _isSubmitting = false;

  static const _actionTypes = ['product', 'work', 'company_profile'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final companyId = auth.company?.id;

    final form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImagePicker(l10n),
          const SizedBox(height: 16),
          _buildTextField(l10n),
          const SizedBox(height: 16),
          _buildActionTypeDropdown(l10n),
          const SizedBox(height: 16),
          _buildActionTargetField(context, companyId, l10n),
          const SizedBox(height: 24),
          _buildSubmitButton(l10n),
        ],
      ),
    );

    if (!widget.embedded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.poster_create)),
        body: form,
      );
    }
    return form;
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(l10n.poster_upload_image, style: TextStyle(color: Colors.grey[500])),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(AppLocalizations l10n) {
    return TextFormField(
      controller: _textController,
      decoration: InputDecoration(labelText: l10n.poster_text, border: const OutlineInputBorder()),
      maxLines: 2,
      validator: (v) => v == null || v.trim().isEmpty ? 'Text is required' : null,
    );
  }

  Widget _buildActionTypeDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _actionType,
      decoration: InputDecoration(labelText: l10n.poster_action_type, border: const OutlineInputBorder()),
      items: _actionTypes.map((t) => DropdownMenuItem(value: t, child: Text(_actionTypeLabel(t, l10n)))).toList(),
      onChanged: (v) => setState(() {
        _actionType = v!;
        _selectedActionId = null;
        _selectedActionName = null;
      }),
    );
  }

  Widget _buildActionTargetField(BuildContext context, int? companyId, AppLocalizations l10n) {
    if (_actionType == 'company_profile') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(l10n.poster_action_auto, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    final hasSelection = _selectedActionId != null;
    final hint = _actionType == 'product' ? l10n.poster_select_product : l10n.poster_select_work;

    return InkWell(
      onTap: () => _pickActionTarget(context, companyId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(hasSelection ? Icons.check_circle : Icons.arrow_forward_ios, size: 18, color: hasSelection ? Colors.green : Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasSelection ? _selectedActionName! : hint,
                style: TextStyle(color: hasSelection ? Colors.black87 : Colors.grey[500], fontWeight: hasSelection ? FontWeight.w500 : FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return FilledButton(
      onPressed: _isSubmitting ? null : () => _submit(context),
      child: _isSubmitting
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(l10n.poster_create),
    );
  }

  String _actionTypeLabel(String type, AppLocalizations l10n) {
    return switch (type) {
      'product' => l10n.products,
      'work' => l10n.company_work_title,
      'company_profile' => l10n.company_profile,
      _ => type,
    };
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _pickActionTarget(BuildContext context, int? companyId) async {
    if (companyId == null) return;
    final PickerItem? picked;
    if (_actionType == 'product') {
      picked = await showProductPicker(context, companyId);
    } else if (_actionType == 'work') {
      picked = await showWorkPicker(context, companyId);
    } else {
      picked = null;
    }
    if (picked == null || !mounted) return;
    final actionId = picked.id;
    final actionName = picked.name;
    setState(() {
      _selectedActionId = actionId;
      _selectedActionName = actionName;
    });
  }

  Future<void> _submit(BuildContext context) async {
    final companyId = ref.read(authProvider).company?.id;
    if (!_formKey.currentState!.validate() || companyId == null) return;
    setState(() => _isSubmitting = true);
    try {
      final dataSource = getIt<PosterRemoteDataSource>();
      await dataSource.createPoster(
        companyId: companyId,
        text: _textController.text.trim(),
        actionType: _actionType,
        actionId: _selectedActionId,
        imagePath: _imagePath,
      );
      ref.invalidate(companyPostersProvider);
      if (context.mounted) {
        ToastService.success(context, 'Success', 'Poster created');
        context.pop();
      }
    } catch (e) {
      if (context.mounted) ToastService.error(context, 'Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
