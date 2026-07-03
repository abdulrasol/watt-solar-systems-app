import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/admin/presentation/models/admin_module.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_dashboard_card.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
     child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1180
              ? 4
              : width >= 760
              ? 3
              : 2;

          return GridView.builder(
            itemCount: AdminModules.dashboardCards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 2 ? 0.62 : 1.1,
            ),
            itemBuilder: (context, index) {
              return AdminDashboardCard(module: AdminModules.dashboardCards[index]);
            },
          );
        },
      ),
    );
  }
}
