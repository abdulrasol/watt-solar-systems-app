import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_card.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/work_gallery_sheet.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../common_widgets.dart';

class CompanyWorksTab extends ConsumerWidget {
  final Company company;

  const CompanyWorksTab({super.key, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(publicCompanyWorksProvider(company.id));

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyFeatureBanner(
            icon: Icons.work_outline_rounded,
            title: l10n.company_work_public_title,
            subtitle: l10n.company_work_public_subtitle,
          ),
          SizedBox(height: 14.h),
          if (state.isLoading && state.works.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.works.isEmpty)
            _WorksStatusCard(
              message: state.error!,
              actionLabel: l10n.try_again,
              onPressed: () => ref
                  .read(publicCompanyWorksProvider(company.id).notifier)
                  .fetchWorks(isRefresh: true),
            )
          else if (state.works.isEmpty)
            _WorksStatusCard(message: l10n.company_work_public_empty)
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.works.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppBreakpoints.adaptiveGridCount(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 2,
                ),
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: AppBreakpoints.isMobile(context) ? 1.0 : 0.82,
              ),
              itemBuilder: (context, index) {
                final work = state.works[index];
                return CompanyWorkCard(
                  work: work,
                  onTap: () => WorkGallerySheet.show(
                    context,
                    work: work,
                    isPublicView: true,
                  ),
                );
              },
            ),
            if (state.hasMore || state.isMoreLoading) ...[
              SizedBox(height: 16.h),
              Center(
                child: FilledButton.tonal(
                  onPressed: state.isMoreLoading
                      ? null
                      : () => ref
                            .read(
                              publicCompanyWorksProvider(company.id).notifier,
                            )
                            .nextPage(),
                  child: state.isMoreLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.load_more),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _WorksStatusCard extends StatelessWidget {
  const _WorksStatusCard({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 36.sp,
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (actionLabel != null && onPressed != null) ...[
            SizedBox(height: 12.h),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
