import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/shared/domain/company/company_contact.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Card widget displaying a single company contact.
class ContactCard extends ConsumerWidget {
  final CompanyContact contact;
  final VoidCallback? onDelete;

  const ContactCard({super.key, required this.contact, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Iconsax.user, color: colors.primary),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Iconsax.trash, color: colors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contact.name,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ),
          const SizedBox(height: 10),
          _MetaRow(icon: Iconsax.sms, value: contact.email ?? '-', colors: colors),
          const SizedBox(height: 8),
          _MetaRow(icon: Iconsax.call, value: contact.phone ?? '-', colors: colors),
          if ((contact.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetaRow(icon: Iconsax.note, value: contact.notes!, colors: colors),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.value, required this.colors});

  final IconData icon;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
