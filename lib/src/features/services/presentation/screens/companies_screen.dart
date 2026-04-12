import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/services/presentation/providers/public_services_provider.dart';
import 'package:solar_hub/src/features/services/presentation/widgets/company_card.dart';
import 'package:solar_hub/src/features/services/presentation/widgets/services_header.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  final CompanyType type;

  const CompaniesScreen({super.key, required this.type});

  @override
  ConsumerState<CompaniesScreen> createState() =>
      _ServicesCompaniesScreenState();
}

class _ServicesCompaniesScreenState extends ConsumerState<CompaniesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(servicesCompaniesProvider(widget.type));
    final notifier = ref.read(servicesCompaniesProvider(widget.type).notifier);
    final padding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ServicesHeader(
                  title: widget.type.name,
                  subtitle: l10n.services_companies_subtitle,
                  badge: l10n.services_companies_found(state.totalItems),
                ),
                SizedBox(height: 16.h),
                _FiltersSection(
                  searchController: _searchController,
                  cities: state.cities,
                  selectedCityId: state.query.cityId,
                  onCityChanged: notifier.selectCity,
                  onSearchChanged: notifier.updateSearch,
                ),
                SizedBox(height: 16.h),
                if (state.error != null && !state.isLoading)
                  _ErrorBanner(
                    message: state.error!,
                    onRetry: notifier.refresh,
                  ),
              ]),
            ),
          ),
          if (state.isLoading && state.companies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: LoadingWidget.widget(context: context)),
            )
          else if (state.companies.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding.copyWith(top: 0),
                child: _EmptyState(message: l10n.services_no_companies_found),
              ),
            )
          else
            SliverPadding(
              padding: padding.copyWith(top: 0),
              sliver: SliverList.builder(
                itemBuilder: (context, index) {
                  final company = state.companies[index];
                  return CompanyCard(
                    company: company,
                    onTap: () =>
                        context.push('/services/company/${company.id}'),
                  );
                },
                itemCount: state.companies.length,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final TextEditingController searchController;
  final List<City> cities;
  final int? selectedCityId;
  final ValueChanged<City?> onCityChanged;
  final ValueChanged<String> onSearchChanged;

  const _FiltersSection({
    required this.searchController,
    required this.cities,
    required this.selectedCityId,
    required this.onCityChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    City? selectedCity;
    for (final city in cities) {
      if (city.id == selectedCityId) {
        selectedCity = city;
        break;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final cityField = DropdownButtonFormField<City?>(
          initialValue: selectedCity,
          decoration: InputDecoration(
            labelText: l10n.city,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          items: [
            DropdownMenuItem<City?>(
              value: null,
              child: Text(l10n.services_all_cities),
            ),
            ...cities.map(
              (city) =>
                  DropdownMenuItem<City?>(value: city, child: Text(city.name)),
            ),
          ],
          onChanged: onCityChanged,
        );

        final searchField = ValueListenableBuilder<TextEditingValue>(
          valueListenable: searchController,
          builder: (context, value, child) {
            return TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.services_search_companies,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            );
          },
        );

        if (isCompact) {
          return Column(
            children: [
              cityField,
              SizedBox(height: 12.h),
              searchField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: cityField),
            SizedBox(width: 12.w),
            Expanded(flex: 3, child: searchField),
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.services_retry)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }
}
