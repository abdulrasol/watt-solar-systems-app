import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/services/presentation/providers/public_services_provider.dart';
import 'package:solar_hub/src/features/services/presentation/widgets/company_type_card.dart';

class ServicesExplorerScreen extends ConsumerWidget {
  final bool embedded;

  const ServicesExplorerScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(publicServiceTypesProvider);
    final l10n = AppLocalizations.of(context)!;
    final padding = embedded
        ? EdgeInsets.fromLTRB(0, 0, 0, 16.h)
        : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(publicServiceTypesProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // SliverPadding(
          //   padding: padding,
          //   sliver: SliverList(
          //     delegate: SliverChildListDelegate([
          //       ServicesHeader(title: l10n.services, subtitle: l10n.services_explorer_subtitle, badge: l10n.services_choose_category),
          //       SizedBox(height: 16.h),
          //     ]),
          //   ),
          // ),
          typesAsync.when(
            data: (types) {
              if (types.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: padding,
                    child: _EmptyState(message: l10n.services_no_categories),
                  ),
                );
              }

              final width = MediaQuery.of(context).size.width;
              final crossAxisCount = width >= 1100
                  ? 4
                  : width >= 720
                  ? 3
                  : 2;

              return SliverPadding(
                padding: padding.copyWith(
                  top: 10.h,
                  left: 10.w,
                  right: 10.w,
                  bottom: 10.h,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final type = types[index];
                    return CompanyTypeCard(
                      type: type,
                      onTap: () => _openCompanies(context, type),
                    );
                  }, childCount: types.length),
                ),
              );
            },
            error: (error, stackTrace) => SliverToBoxAdapter(
              child: Padding(
                padding: padding,
                child: _EmptyState(message: error.toString()),
              ),
            ),
            loading: () => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: LoadingWidget.widget(context: context)),
            ),
          ),
        ],
      ),
    );
  }

  void _openCompanies(BuildContext context, CompanyType type) {
    final uri = Uri(
      path: '/services/companies',
      queryParameters: {
        'typeId': '${type.id}',
        'typeCode': type.code,
        'typeName': type.name,
      },
    );
    context.push(uri.toString());
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
