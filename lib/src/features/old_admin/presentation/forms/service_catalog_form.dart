import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/beautiful_mention.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceCatalogForm extends StatefulWidget {
  final ServiceCatalogItem? item;
  final Function(Map<String, dynamic> data) onSubmit;

  const ServiceCatalogForm({super.key, this.item, required this.onSubmit});

  @override
  State<ServiceCatalogForm> createState() => _ServiceCatalogFormState();
}

class _ServiceCatalogFormState extends State<ServiceCatalogForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _routeController;
  late bool _isActive;
  late int _sortOrder;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.item?.code ?? '');
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.item?.category ?? 'general',
    );
    _routeController = TextEditingController(text: widget.item?.route ?? '');
    _isActive = widget.item?.isActive ?? true;
    _sortOrder = widget.item?.sortOrder ?? 0;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    'Service Code *',
                    _codeController,
                    enabled: widget.item == null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Service Name *', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  if (isMobile)
                    Column(
                      children: [
                        _buildTextField('Category', _categoryController),
                        const SizedBox(height: 16),
                        _buildTextField('Route', _routeController),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Category',
                            _categoryController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField('Route', _routeController),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildSwitch(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.item == null ? 'Add Service' : 'Edit Service',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Iconsax.close_circle_bold,
            color: Colors.grey,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return BeautifulMention(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14),
      inputDecoration: AppTheme.inputDecoration(label, label).copyWith(
        fillColor: enabled ? null : Colors.grey.withValues(alpha: 0.1),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      },
    );
  }

  Widget _buildSwitch() {
    return Row(
      children: [
        Text(
          'Active Status',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const Spacer(),
        Switch(
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          activeThumbColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final data = {
              'code': _codeController.text,
              'name': _nameController.text,
              'description': _descriptionController.text,
              'category': _categoryController.text,
              'is_active': _isActive,
              'sort_order': _sortOrder,
              if (_routeController.text.isNotEmpty)
                'route': _routeController.text,
            };
            widget.onSubmit(data);
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.item == null ? 'CREATE SERVICE' : 'UPDATE SERVICE',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}
