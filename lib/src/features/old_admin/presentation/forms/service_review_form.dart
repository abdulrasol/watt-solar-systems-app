import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/status_helper.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceReviewForm extends StatefulWidget {
  final CompanyService? service;
  final ServiceRequest? request;
  final Function(Map<String, dynamic> data) onSubmit;

  const ServiceReviewForm({
    super.key,
    this.service,
    this.request,
    required this.onSubmit,
  }) : assert(
         service != null || request != null,
         'Either service or request must be provided',
       );

  @override
  State<ServiceReviewForm> createState() => _ServiceReviewFormState();
}

class _ServiceReviewFormState extends State<ServiceReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late String _status;
  late TextEditingController _notesController;
  late DateTime _startDate;
  late DateTime _endDate;
  String get _serviceName =>
      widget.service?.serviceName ??
      widget.request?.serviceName ??
      'Unknown Service';

  @override
  void initState() {
    super.initState();
    _status =
        widget.service?.status?.toLowerCase() ??
        widget.request?.status.toLowerCase() ??
        'pending';
    _notesController = TextEditingController(
      text: widget.service?.notes ?? widget.request?.notes ?? '',
    );
    _startDate = widget.service?.startsAt != null
        ? DateTime.parse(widget.service!.startsAt!)
        : (widget.request?.requestedAt != null
              ? DateTime.parse(widget.request!.requestedAt!)
              : DateTime.now());
    _endDate = widget.service?.endsAt != null
        ? DateTime.parse(widget.service!.endsAt!)
        : DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          top: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
                _buildStatusSection(),
                const SizedBox(height: 24),
                _buildNotesField(),
                const SizedBox(height: 24),
                _buildDateSection(isMobile),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.request != null ? 'Review Request' : 'Review Service',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _serviceName,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
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

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusOption('pending', 'Pending', AppTheme.warningColor),
            _buildStatusOption('active', 'Active', AppTheme.successColor),
            _buildStatusOption('rejected', 'Rejected', AppTheme.errorColor),
            _buildStatusOption('suspended', 'Suspended', Colors.grey),
            _buildStatusOption('cancelled', 'Cancelled', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(String status, String label, Color color) {
    final isSelected = _status == status;
    return InkWell(
      onTap: () => setState(() => _status = status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              StatusHelper.getStatusIcon(status),
              color: isSelected ? color : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: AppTheme.inputDecoration(
            'Notes',
            'Add notes about this service review',
          ).copyWith(contentPadding: const EdgeInsets.all(16)),
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDateSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Period',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: [
              _buildDateField(
                label: 'Start Date',
                date: _startDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'End Date *',
                date: _endDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'End Date *',
                  date: _endDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Iconsax.calendar_bold,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final data = {
              'status': _status,
              'notes': _notesController.text.trim(),
              'starts_at': _startDate.toUtc().toIso8601String(),
              'ends_at': _endDate.toUtc().toIso8601String(),
            };
            widget.onSubmit(data);
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
        child: const Text(
          'SUBMIT REVIEW',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}
