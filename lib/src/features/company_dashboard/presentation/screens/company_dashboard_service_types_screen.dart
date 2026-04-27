import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/features/service_types/domain/repositories/service_type_repository.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompanyDashboardServiceTypesScreen extends ConsumerStatefulWidget {
  const CompanyDashboardServiceTypesScreen({super.key});

  @override
  ConsumerState<CompanyDashboardServiceTypesScreen> createState() =>
      _CompanyDashboardServiceTypesScreenState();
}

class _CompanyDashboardServiceTypesScreenState
    extends ConsumerState<CompanyDashboardServiceTypesScreen> {
  final ServiceTypeRepository _repository = getIt<ServiceTypeRepository>();
  bool _isLoading = true;
  String? _error;
  List<ServiceType> _items = const [];
  final Set<int> _busyIds = <int>{};

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
      final items = await _repository.listPublicServiceTypes();
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

    return CompanyPageScaffold(
      child: _isLoading && _items.isEmpty
          ? AdminLoadingState(
              icon: Icons.layers_outlined,
              message: l10n.service_types_loading,
            )
          : _error != null && _items.isEmpty
          ? AdminErrorState(error: _error!, onRetry: _load)
          : SingleChildScrollView(
              padding: AppBreakpoints.pagePadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.contentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.service_types,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.service_types_company_subtitle,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(height: 20),
                      if (_items.isEmpty)
                        AdminEmptyState(
                          icon: Icons.layers_outlined,
                          title: l10n.service_types_empty_title,
                          subtitle: l10n.service_types_empty_subtitle,
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final columns = width >= 1100
                                ? 3
                                : width >= 700
                                ? 2
                                : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: columns == 1 ? 2.7 : 2.0,
                                  ),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final isBusy = _busyIds.contains(item.id);
                                return _CompanyServiceTypeCard(
                                  item: item,
                                  isBusy: isBusy,
                                  onToggle: () => _toggle(item),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _toggle(ServiceType item) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyIds.add(item.id));
    try {
      final selected = await _repository.toggleCompanyServiceType(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (entry) => entry.id == item.id
                  ? entry.copyWith(isServed: selected)
                  : entry,
            )
            .toList(growable: false);
      });
      ToastService.success(
        context,
        l10n.success,
        selected
            ? l10n.service_types_marked_served
            : l10n.service_types_unmarked_served,
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(item.id));
      }
    }
  }
}

class _CompanyServiceTypeCard extends StatelessWidget {
  final ServiceType item;
  final bool isBusy;
  final VoidCallback onToggle;

  const _CompanyServiceTypeCard({
    required this.item,
    required this.isBusy,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isServed
              ? AppTheme.primaryColor.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              child: item.image?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.layers_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : const Icon(
                      Icons.layers_outlined,
                      color: AppTheme.primaryColor,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
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
          const SizedBox(width: 12),
          isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FilledButton.tonal(
                  onPressed: onToggle,
                  child: Text(
                    item.isServed
                        ? l10n.service_types_served
                        : l10n.service_types_mark_served,
                  ),
                ),
        ],
      ),
    );
  }
}
