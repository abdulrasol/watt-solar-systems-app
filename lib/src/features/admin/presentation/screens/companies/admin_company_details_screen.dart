import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_company_details_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/company_status_form.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_review_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_section_header.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_service_card.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/member_list_item.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/status_badge.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminCompanyDetailsScreen extends ConsumerStatefulWidget {
  const AdminCompanyDetailsScreen({super.key, required this.companyId});

  final int companyId;

  @override
  ConsumerState<AdminCompanyDetailsScreen> createState() =>
      _AdminCompanyDetailsScreenState();
}

class _AdminCompanyDetailsScreenState
    extends ConsumerState<AdminCompanyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(adminCompanyDetailsProvider.notifier);
    notifier.setCompanyId(widget.companyId);
    Future.microtask(() => notifier.fetchDetails());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompanyDetailsProvider);

    return AdminPageScaffold(
      // title: 'Company Details',
      // subtitle: 'Detailed company data loads only when a company is opened.',
      actions: [
        if (state.details != null)
          FilledButton.icon(
            onPressed: () => _showStatusUpdateForm(context),
            icon: const Icon(Iconsax.edit_bold),
            label: const Text('Update Status'),
          ),
      ],
      child: state.isLoading && state.details == null
          ? const AdminLoadingState(
              icon: Iconsax.building_bold,
              message: 'Loading company details...',
            )
          : state.error != null && state.details == null
          ? AdminErrorState(
              error: state.error!,
              onRetry: () =>
                  ref.read(adminCompanyDetailsProvider.notifier).fetchDetails(),
            )
          : _buildContent(context, state.details!),
    );
  }

  Widget _buildContent(BuildContext context, AdminCompanyDetails details) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminCompanyDetailsProvider.notifier).fetchDetails(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final info = _buildInfoSection(context, details);
          final services = _buildServicesSection(details);

          return ListView(
            children: [
              _buildHeroCard(context, details),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    Expanded(child: services),
                  ],
                )
              else ...[
                info,
                const SizedBox(height: 16),
                services,
              ],
              const SizedBox(height: 16),
              _buildMembersSection(details),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AdminCompanyDetails details) {
    final company = details.company;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.14),
            Theme.of(context).cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.14),
            backgroundImage: company.logo != null
                ? NetworkImage(company.logo!)
                : null,
            child: company.logo == null
                ? const Icon(
                    Iconsax.building_bold,
                    color: AppTheme.primaryColor,
                    size: 34,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            company.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          StatusBadge(status: company.status),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _Tag(label: 'Tier', value: company.tier ?? 'Standard'),
              _Tag(label: 'Type', value: company.type ?? 'N/A'),
              _Tag(label: 'B2B', value: company.allowsB2B ? 'Yes' : 'No'),
              _Tag(label: 'B2C', value: company.allowsB2C ? 'Yes' : 'No'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, AdminCompanyDetails details) {
    final company = details.company;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Company Profile',
            subtitle: 'Core account and business information.',
          ),
          _InfoRow(label: 'Address', value: company.address ?? 'N/A'),
          _InfoRow(label: 'City', value: company.city?.name ?? 'N/A'),
          _InfoRow(label: 'Currency', value: company.currencyLabel ?? 'N/A'),
          _InfoRow(
            label: 'Categories',
            value: company.categoryNames.isEmpty
                ? 'N/A'
                : company.categoryNames.join(', '),
          ),
          _InfoRow(
            label: 'Description',
            value: company.description?.isNotEmpty == true
                ? company.description!
                : 'No description',
          ),
          if (details.financials.isNotEmpty) ...[
            const SizedBox(height: 16),
            const AdminSectionHeader(
              title: 'Financials',
              subtitle: 'Aggregated values returned by the backend.',
            ),
            ...details.financials.entries.map(
              (entry) => _InfoRow(label: entry.key, value: '${entry.value}'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(AdminCompanyDetails details) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Company Services',
            subtitle: 'Review subscription and activation status.',
          ),
          if (details.services.isEmpty)
            const AdminEmptyState(
              icon: Iconsax.category_bold,
              title: 'No services assigned',
            )
          else
            Column(
              children: details.services
                  .map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CompanyServiceCard(
                        service: service,
                        onToggle: () => _showServiceReviewForm(service),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(AdminCompanyDetails details) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Members',
            subtitle: 'Company users returned with this account.',
          ),
          if (details.members.isEmpty)
            const AdminEmptyState(
              icon: Iconsax.people_bold,
              title: 'No members found',
            )
          else
            Column(
              children: details.members
                  .map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MemberListItem(member: member),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _showStatusUpdateForm(BuildContext context) {
    final currentStatus =
        ref.read(adminCompanyDetailsProvider).details?.company.status ??
        'pending';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CompanyStatusForm(
        currentStatus: currentStatus,
        onSubmit: (status) =>
            ref.read(adminCompanyDetailsProvider.notifier).updateStatus(status),
      ),
    );
  }

  void _showServiceReviewForm(CompanyService service) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ServiceReviewForm(
        service: service,
        onSubmit: (data) => ref
            .read(adminCompanyDetailsProvider.notifier)
            .toggleService(service.serviceCode, data),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
