import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/service_types/company_service_type_card.dart';
import 'package:solar_hub/src/features/service_types/domain/repositories/service_type_repository.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Company service types selection screen.
class CompanyDashboardServiceTypesScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyDashboardServiceTypesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardServiceTypesScreen> createState() => _CompanyDashboardServiceTypesScreenState();
}

class _CompanyDashboardServiceTypesScreenState extends ConsumerState<CompanyDashboardServiceTypesScreen> {
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
    final colors = ref.watch(appColorsProvider);

    if (_isLoading && _items.isEmpty) {
      return AdminLoadingState(icon: Icons.layers_outlined, message: l10n.service_types_loading);
    }

    if (_error != null && _items.isEmpty) {
      return AdminErrorState(error: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.service_types,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.service_types_company_subtitle,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (_items.isEmpty)
                  AppEmptyState(
                    icon: Icons.layers_outlined,
                    title: l10n.service_types_empty_title,
                    subtitle: l10n.service_types_empty_subtitle,
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1100 ? 3 : width >= 700 ? 2 : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: columns == 1 ? 2.7 : 2.0,
                        ),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isBusy = _busyIds.contains(item.id);
                          return CompanyServiceTypeCard(
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
              (entry) => entry.id == item.id ? entry.copyWith(isServed: selected) : entry,
            )
            .toList(growable: false);
      });
      ToastService.success(
        context,
        l10n.success,
        selected ? l10n.service_types_marked_served : l10n.service_types_unmarked_served,
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
