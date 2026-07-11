import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/company_subscription_request.dart';

class SubscriptionRequestCard extends StatefulWidget {
  final CompanySubscriptionRequest request;
  final VoidCallback onStatusUpdated;

  const SubscriptionRequestCard({
    super.key,
    required this.request,
    required this.onStatusUpdated,
  });

  @override
  State<SubscriptionRequestCard> createState() => _SubscriptionRequestCardState();
}

class _SubscriptionRequestCardState extends State<SubscriptionRequestCard> {
  final _adminRepository = getIt<AdminRepository>();
  bool _isLoading = false;

  Future<void> _reviewRequest(String status) async {
    setState(() => _isLoading = true);
    try {
      await _adminRepository.reviewSubscriptionRequest(
        widget.request.companyId,
        widget.request.id,
        status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request ${status == 'active' ? 'approved' : 'rejected'} successfully')));
      }
      widget.onStatusUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to review request: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImagePreview(BuildContext context) {
    if (widget.request.image == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            WdImagePreview(
              imageUrl: widget.request.image!,
              fit: BoxFit.contain,
              shape: BoxShape.rectangle,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                style: IconButton.styleFrom(backgroundColor: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
      case 'cancelled':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.companyName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.subscriptionPlanName,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      if (req.requestedBy != null)
                        Text(
                          'Requested by: ${req.requestedBy}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      if (req.createdAt != null)
                        Text(
                          'Date: ${dateFormat.format(req.createdAt!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(req.status),
              ],
            ),
            if (req.notes != null && req.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: Text(
                  'Notes: ${req.notes}',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  if (req.image != null)
                    TextButton.icon(
                      onPressed: () => _showImagePreview(context),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('View Receipt'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (req.isPending)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        OutlinedButton(
                          onPressed: _isLoading ? null : () => _reviewRequest('rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _reviewRequest('active'),
                          child: _isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Approve'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
