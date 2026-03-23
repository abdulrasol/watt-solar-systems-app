import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/company_dashboard_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_menu_card.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_strings.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CompanyDashboardPage extends ConsumerStatefulWidget {
  const CompanyDashboardPage({super.key});

  @override
  ConsumerState<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends ConsumerState<CompanyDashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final company = authState.isCompanyMember ? authState.company : null;

    final dashboardAsync = ref.watch(dashboardDataProvider);

    // Navigation helper
    void changePage(int targetIndex, String targetRouteName) {
      ref.read(companyDashboardControllerProvider.notifier).changePage(targetIndex, targetRouteName, isSubscriptionActive: true);
    }

    if (company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.no_company_found, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.not_linked_company),
          ],
        ),
      );
    }

    if (company.status == 'pending') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Iconsax.timer_1_bold, size: 60, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            Text(l10n.verification_pending, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.verification_pending_msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => context.pop(), child: Text(l10n.go_back)),
          ],
        ),
      );
    }

    return dashboardAsync.when(
      loading: () => Center(child: SpinKitCubeGrid(color: Theme.of(context).primaryColor, size: 50.0)),
      error: (error, stackTrace) {
        dPrint(error, stackTrace: stackTrace);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load dashboard data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
      data: (dashboard) {
        final Map<String, dynamic> statsq = {
          'inventory_value': 45000.00,
          'pending_orders': dashboard.deliveryOptions,
          'open_requests': 5,
          'products': dashboard.products,
        };
        final String currencySymbol = "\$";
        dPrint(dashboard.permissions);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome / Header Card
              _wdCard(context, company, l10n, currencySymbol, statsq),

              SizedBox(height: 24.h),

              // // Quick Actions (Stats)
              // GridView(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200.w, mainAxisSpacing: 2.w, crossAxisSpacing: 2.w),
              //   children: [
              //     DashboardMetricCard(
              //       title: l10n.pending_orders,
              //       value: (dashboard.deliveryOptions),
              //       icon: Iconsax.box_time_bold,
              //       color: Colors.blue,
              //       onTap: () => changePage(6, 'orders'),
              //     ),
              //     DashboardMetricCard(
              //       title: l10n.open_requests,
              //       value: (stats['open_requests'] ?? 0),
              //       icon: Iconsax.clipboard_text_bold,
              //       color: Colors.orange,
              //       onTap: () => changePage(3, 'offers'),
              //     ),
              //     DashboardMetricCard(
              //       title: l10n.low_stock,
              //       value: dashboard.members,
              //       icon: Iconsax.warning_2_bold,
              //       color: Colors.redAccent,
              //       onTap: () => changePage(4, 'inventory'),
              //     ),
              //   ],
              // ),

              //     }

              //     return Row(
              //       children: [
              //         Expanded(
              //           child: DashboardMetricCard(
              //             title: l10n.pending_orders,
              //             value: (stats['pending_orders'] ?? 0).toString(),
              //             icon: Iconsax.box_time_bold,
              //             color: Colors.blue,
              //             onTap: () => changePage(6, 'orders'),
              //           ),
              //         ),
              //         SizedBox(width: cardSpacing),
              //         Expanded(
              //           child: DashboardMetricCard(
              //             title: l10n.open_requests,
              //             value: (stats['open_requests'] ?? 0).toString(),
              //             icon: Iconsax.clipboard_text_bold,
              //             color: Colors.orange,
              //             onTap: () => changePage(3, 'offers'),
              //           ),
              //         ),
              //         SizedBox(width: cardSpacing),
              //         Expanded(
              //           child: DashboardMetricCard(
              //             title: l10n.low_stock,
              //             value: '0',
              //             icon: Iconsax.warning_2_bold,
              //             color: Colors.redAccent,
              //             onTap: () => changePage(4, 'inventory'),
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),
              SizedBox(height: 32.h),
              _buildDashboardSection(context, l10n.manage_business, [
                DashboardMenuCard(
                  permission: hasPremissions(AppStrings.ordersPermission),
                  title: l10n.orders,
                  icon: FontAwesomeIcons.clipboardList,
                  color: Colors.deepOrange,
                  onTap: () => changePage(6, 'orders'),
                  // badge: dashboard.products, // TODO
                ),
                DashboardMenuCard(
                  permission: hasPremissions(AppStrings.posPermission),
                  title: l10n.pos,
                  icon: FontAwesomeIcons.cashRegister,
                  color: Colors.purple,
                  onTap: () => changePage(5, 'pos'),
                ),
                DashboardMenuCard(
                  permission: hasPremissions(AppStrings.invoicesPermission),
                  title: l10n.invoices,
                  icon: FontAwesomeIcons.fileInvoiceDollar,
                  color: Colors.teal,
                  onTap: () => changePage(7, 'invoices'),
                  //  badge: dashboard., // TODO
                ),
                DashboardMenuCard(
                  permission: hasPremissions(AppStrings.inventoryPermission),
                  title: l10n.inventory,
                  icon: FontAwesomeIcons.boxesStacked,
                  color: Colors.green,
                  onTap: () => changePage(4, 'inventory'),
                  badge: dashboard.products,
                ),
                DashboardMenuCard(
                  title: l10n.offers,
                  icon: FontAwesomeIcons.bullhorn,
                  color: Colors.orange,
                  onTap: () => changePage(3, 'offers'),
                  badge: dashboard.offers,
                  permission: hasPremissions(AppStrings.offersPermission),
                ),
                DashboardMenuCard(
                  title: l10n.accounting,
                  icon: FontAwesomeIcons.calculator,
                  color: Colors.deepPurple,
                  onTap: () => changePage(8, 'accounting'),
                  permission: hasPremissions(AppStrings.accountantPermission),
                ),
              ]),

              _buildDashboardSection(context, l10n.people, [
                DashboardMenuCard(
                  title: l10n.members,
                  icon: FontAwesomeIcons.users,
                  color: Colors.brown,
                  onTap: () => changePage(10, 'members'),
                  badge: dashboard.members,
                  permission: hasPremissions(AppStrings.membersPermission),
                ),
                DashboardMenuCard(
                  title: l10n.customers,
                  icon: FontAwesomeIcons.userGroup,
                  color: Colors.indigoAccent,
                  onTap: () => changePage(12, 'customers'),
                  badge: dashboard.customers,
                  permission: hasPremissions(AppStrings.customersPermission),
                ),
                DashboardMenuCard(
                  title: l10n.suppliers,
                  icon: Iconsax.shop_bold,
                  color: Colors.purpleAccent,
                  onTap: () => changePage(13, 'suppliers'),
                  permission: hasPremissions(AppStrings.suppliersPermission),
                ),
                DashboardMenuCard(
                  title: l10n.my_purchases,
                  icon: FontAwesomeIcons.bagShopping,
                  color: Colors.pink,
                  onTap: () => changePage(14, 'my_purchases'),
                  badge: dashboard.myPurchases,
                  permission: hasPremissions(AppStrings.mySalesPermission),
                ),
              ]),

              _buildDashboardSection(context, l10n.tools, [
                DashboardMenuCard(
                  title: l10n.analytics,
                  icon: FontAwesomeIcons.chartLine,
                  color: Colors.indigo,
                  onTap: () => changePage(9, 'analytics'),
                  permission: hasPremissions(AppStrings.analyticsPermission),
                ),
                DashboardMenuCard(
                  title: l10n.systems,
                  icon: FontAwesomeIcons.solarPanel,
                  color: Colors.blue,
                  badge: dashboard.systems,
                  onTap: () => changePage(11, 'systems'),
                  permission: hasPremissions(AppStrings.systemsPermission),
                ),
                DashboardMenuCard(
                  title: l10n.delivery,
                  icon: Icons.local_shipping,
                  color: Colors.cyan,
                  onTap: () => changePage(15, 'delivery'),
                  badge: dashboard.deliveryOptions,
                  permission: hasPremissions(AppStrings.deliveryPermission),
                ),
                DashboardMenuCard(
                  title: 'Contacts', //TODO: add translation
                  icon: Iconsax.call_calling_bold,
                  color: Colors.cyan,
                  onTap: () => changePage(16, 'contacts'),
                  badge: dashboard.contacts,
                  permission: hasPremissions(AppStrings.deliveryPermission),
                ),
              ]),

              _buildDashboardSection(context, l10n.settings, [
                DashboardMenuCard(title: l10n.company_profile, icon: Iconsax.building_bold, color: Colors.blueGrey, onTap: () => changePage(1, 'profile')),
                DashboardMenuCard(title: l10n.subscription, icon: FontAwesomeIcons.star, color: Colors.amber, onTap: () => changePage(2, 'subscription')),
                DashboardMenuCard(title: l10n.settings, icon: Iconsax.setting_2_bold, color: Colors.blueGrey, onTap: () => context.push('/settings')),
              ]),

              SizedBox(height: 48.h), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Container _wdCard(BuildContext context, Company company, AppLocalizations l10n, String currencySymbol, Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: company.logo != null ? CachedNetworkImageProvider(company.logo!) : null,
                  child: company.logo == null
                      ? Text(
                          company.name.isNotEmpty ? company.name[0] : 'C',
                          style: TextStyle(fontSize: 28, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _getTierTranslated(context, company.tier ?? 'Standard'),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cash Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.wallet_3_bold, color: Colors.white.withValues(alpha: 0.8), size: 16),
                          const SizedBox(width: 6),
                          Text(l10n.balance, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          NumberFormat.currency(symbol: currencySymbol).format(0.0), // Using 0.0 as balance isn't in Company model yet
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(horizontal: 16)),

                // Inventory Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.box_bold, color: Colors.white.withValues(alpha: 0.8), size: 16),
                          const SizedBox(width: 6),
                          Text(l10n.stock_value, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          NumberFormat.currency(symbol: currencySymbol).format(stats['inventory_value'] ?? 0.0),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTierTranslated(BuildContext context, String tierName) {
    // Basic mapping, ideally handled cleanly by a utility function or extension on Tier enum
    return tierName; // Fallback
  }

  Widget _buildDashboardSection(BuildContext context, String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.h),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            double childAspectRatio = 1.1.r;

            if (constraints.maxWidth > 1400) {
              crossAxisCount = 6;
              childAspectRatio = 1.2.r;
            } else if (constraints.maxWidth > 1100) {
              crossAxisCount = 5;
              childAspectRatio = 1.1.r;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 4;
              childAspectRatio = 1.0.r;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 1.0.r;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,

              //crossAxisSpacing: 0.w,
              //  mainAxisSpacing: 0.h,
              childAspectRatio: childAspectRatio,
              children: children,
            );
          },
        ),
      ],
    );
  }

  Permissions hasPremissions(String action) {
    return ref
        .read(dashboardDataProvider)
        .maybeWhen(
          data: (data) {
            final perm = data.permissions[action];
            if (perm != null) {
              if (perm == AppStrings.writePremeission) {
                return Permissions.write;
              } else if (perm == AppStrings.readPremeission) {
                return Permissions.read;
              } else if (perm == AppStrings.nonePremeission) {
                return Permissions.none;
              }
            }
            if (data.role == 'owner' || data.role == 'admin') {
              return Permissions.write;
            }
            return Permissions.none;
          },
          orElse: () => Permissions.none,
        );
  }
}
