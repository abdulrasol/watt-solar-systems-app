import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/battery_calculator/count_calculator.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/battery_calculator/time_calculator.dart';

// final DataController dataContrller = Get.find();

class BatteryCalculator extends ConsumerStatefulWidget {
  const BatteryCalculator({super.key});

  @override
  ConsumerState<BatteryCalculator> createState() => _BatteryCalculatorState();
}

class _BatteryCalculatorState extends ConsumerState<BatteryCalculator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // No longer using pageSelector for BottomNav, using TabBar for better UX in Sliver
  List<Widget> pages = [TimeCalculator(), CountCalculator()];
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.orange;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              backgroundColor: isDark ? Colors.grey[900] : primaryColor,
              title: Text(
                AppLocalizations.of(context)!.battery_calculator_title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                // title: Text(AppLocalizations.of(context)?.battery-calculator ?? 'battery-calculator', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withValues(alpha: 0.8),
                            primaryColor.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Hero(
                        tag: '/calculator/battery',
                        child: Image.asset(
                          'assets/png/cards/battery.png',
                          height: 120,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: const Icon(IonIcons.timer),
                    text: AppLocalizations.of(context)!.time_calculate,
                  ),
                  Tab(
                    icon: const Icon(FontAwesome.car_battery_solid),
                    text: AppLocalizations.of(context)!.count_calculate,
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Wrap in SingleChildScrollView if needed, but the child widgets likely handle scrolling or are small
            // Adding padding/styling wrapper
            _buildTabContent(pages[0]),
            _buildTabContent(pages[1]),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget child) {
    // A wrapper to ensure consistent styling or padding if the child widgets are raw
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child:
          child, // The child pages (TimeCalculator/CountCalculator) should ideally be scrollable or fitted
    );
  }
}
