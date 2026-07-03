import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/service_types/domain/models/service_type_form_payload.dart';
import 'package:solar_hub/src/features/service_types/domain/repositories/service_type_repository.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminServiceTypesScreen extends ConsumerStatefulWidget {
  const AdminServiceTypesScreen({super.key});

  @override
  ConsumerState<AdminServiceTypesScreen> createState() =>
      _AdminServiceTypesScreenState();
}

class _AdminServiceTypesScreenState
    extends ConsumerState<AdminServiceTypesScreen> {
  final ServiceTypeRepository _repository = getIt<ServiceTypeRepository>();
  bool _isLoading = true;
  String? _error;
  List<ServiceType> _items = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _repository.listAdminServiceTypes();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdminPageScaffold(
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l10n.service_types_add),
        ),
      ],
      child: _isLoading && _items.isEmpty
          ? AdminLoadingState(
              icon: Icons.layers_outlined,
              message: l10n.service_types_loading,
            )
          : _error != null && _items.isEmpty
          ? AdminErrorState(error: _error!, onRetry: _load)
          : _items.isEmpty
          ? AdminEmptyState(
              icon: Icons.layers_outlined,
              title: l10n.service_types_empty_title,
              subtitle: l10n.service_types_empty_subtitle,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _AdminServiceTypeCard(
                    item: item,
                    onEdit: () => _openForm(item: item),
                    onDelete: () => _deleteItem(item),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _deleteItem(ServiceType item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.service_types_delete_title),
        content: Text(l10n.service_types_delete_message(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteServiceType(item.id);
      if (!mounted) return;
      ToastService.success(context, l10n.success, l10n.service_types_deleted);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openForm({ServiceType? item}) async {
    final result = await showModalBottomSheet<_AdminServiceTypeFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminServiceTypeFormSheet(item: item),
    );
    if (result == null) return;

    try {
      if (item == null) {
        await _repository.createServiceType(result.payload);
      } else {
        await _repository.updateServiceType(item.id, result.payload);
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ToastService.success(
        context,
        l10n.success,
        item == null ? l10n.service_types_created : l10n.service_types_updated,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ToastService.error(context, l10n.error, e.toString());
    }
  }
}

class _AdminServiceTypeCard extends StatelessWidget {
  final ServiceType item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminServiceTypeCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceTypeImage(image: item.image),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.service_types_companies_count(item.companiesCount),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceTypeImage extends StatelessWidget {
  final String? image;

  const _ServiceTypeImage({this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 72,
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        child: image?.isNotEmpty == true
            ? CachedNetworkImage(
                imageUrl: image!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.layers_outlined),
              )
            : const Icon(Icons.layers_outlined, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _AdminServiceTypeFormResult {
  final ServiceTypeFormPayload payload;

  const _AdminServiceTypeFormResult(this.payload);
}

class _AdminServiceTypeFormSheet extends StatefulWidget {
  final ServiceType? item;

  const _AdminServiceTypeFormSheet({this.item});

  @override
  State<_AdminServiceTypeFormSheet> createState() =>
      _AdminServiceTypeFormSheetState();
}

class _AdminServiceTypeFormSheetState
    extends State<_AdminServiceTypeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item == null
                        ? l10n.service_types_add
                        : l10n.service_types_edit,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.name),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.company_public_services_title_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: l10n.description),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(l10n.service_types_pick_image),
                  ),
                  if (_pickedImage != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_pickedImage!.path),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ] else if (widget.item?.image?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _ServiceTypeImage(image: widget.item!.image),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(
                        widget.item == null
                            ? l10n.service_types_create_action
                            : l10n.service_types_update_action,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _pickedImage = image);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _AdminServiceTypeFormResult(
        ServiceTypeFormPayload(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imagePath: _pickedImage?.path,
        ),
      ),
    );
  }
}
