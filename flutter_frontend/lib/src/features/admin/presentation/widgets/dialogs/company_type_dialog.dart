import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:watt/src/utils/helper_methods.dart';

class CompanyTypeDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? type;
  const CompanyTypeDialog({super.key, this.type});

  @override
  ConsumerState<CompanyTypeDialog> createState() => _CompanyTypeDialogState();
}

class _CompanyTypeDialogState extends ConsumerState<CompanyTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  bool _submitting = false;
  bool _loading = false;
  
  final List<String> _allFeatures = ['store', 'offers', 'contacts', 'ads', 'accounting'];
  List<Map<String, dynamic>> _allPlans = [];
  
  final List<String> _selectedFeatures = [];
  final List<int> _selectedPlans = [];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.type?['code']);
    _nameController = TextEditingController(text: widget.type?['name']);
    
    if (widget.type != null) {
      final features = widget.type!['allowed_features'] as List? ?? [];
      for (var f in features) {
        _selectedFeatures.add(f as String);
      }
      final plans = widget.type!['allowed_subscription_plans'] as List? ?? [];
      for (var p in plans) {
        if (p['id'] != null) _selectedPlans.add(p['id'] as int);
      }
    }
    
    _fetchData();
  }
  
  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final dio = DioService();
      
      
      
      final plansRes = await dio.get(AppUrls.adminSubscriptions, queryParameters: {'page_size': 100});
      if (plansRes.body is Map) {
        _allPlans = (plansRes.body['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      } else if (plansRes.body is List) {
        _allPlans = (plansRes.body as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      dPrint('Error fetching services/plans: $e', tag: 'CompanyTypeDialog');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.type == null ? 'Add Company Type' : 'Edit Company Type'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading 
            ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Code', hintText: 'e.g. installer'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  enabled: !_submitting,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Installer'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  enabled: !_submitting,
                ),
                const SizedBox(height: 24),
                Text('Allowed Features', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allFeatures.map((feature) {
                    final isSelected = _selectedFeatures.contains(feature);
                    return FilterChip(
                      label: Text(feature),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeatures.add(feature);
                          } else {
                            _selectedFeatures.remove(feature);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Allowed Subscription Plans', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allPlans.map((plan) {
                    final isSelected = _selectedPlans.contains(plan['id']);
                    return FilterChip(
                      label: Text(plan['name'] ?? ''),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPlans.add(plan['id'] as int);
                          } else {
                            _selectedPlans.remove(plan['id'] as int);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting || _loading ? null : _submit,
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final dio = DioService();
      final data = {
        'ctype': _codeController.text.trim(),
        'name': _nameController.text.trim(),
        'allowed_features': _selectedFeatures,
        'allowed_subscription_plans': _selectedPlans,
      };
      if (widget.type == null) {
        await dio.post(AppUrls.adminCompanyTypes, data: data);
        if (mounted) ToastService.success(context, 'Success', 'Company type created successfully');
      } else {
        await dio.put(AppUrls.adminCompanyType(widget.type!['id'] as int), data: data);
        if (mounted) ToastService.success(context, 'Success', 'Company type updated successfully');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      dPrint('Error saving company type: $e', tag: 'CompanyTypeDialog');
      if (mounted) ToastService.error(context, 'Error', 'Failed to save company type');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
