import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:solar_hub/layouts/calculator/calculator.dart';
import 'package:solar_hub/layouts/hub/community_share/community_share.dart';
import 'package:solar_hub/layouts/store/store.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List pages = [Calculator(), CommunityShare(), Store()];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Solar Hub',
      //     style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
      //   ),
      //   //  backgroundColor: Colors.orange.shade700,
      //   centerTitle: true,
      // ),
      body: pages[currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: Icon(FontAwesomeIcons.calculator),
            title: Text("Solar Calculator"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.hub_outlined),
            title: Text("Hub"),
            selectedColor: Colors.orange,
          ),

          SalomonBottomBarItem(
            icon: Icon(FontAwesomeIcons.store),
            title: Text("Shop"),
            selectedColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Calculate, Design, and Shop your Solar System!',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCalculatorCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to calculator screen
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.calculate, size: 40, color: Colors.orange),
              SizedBox(width: 16),
              Text('Start Solar Calculator', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final products = [
      {'icon': FontAwesomeIcons.solarPanel, 'name': 'Solar Panels'},
      {'icon': FontAwesomeIcons.batteryFull, 'name': 'Batteries'},
      {'icon': FontAwesomeIcons.bolt, 'name': 'Inverters'},
      {'icon': FontAwesomeIcons.plugCircleBolt, 'name': 'Chargers'},
      {'icon': FontAwesomeIcons.screwdriverWrench, 'name': 'Accessories'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigate to product category
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  product['icon'] as IconData,
                  size: 36,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                Text(
                  product['name'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBundleCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.star_rate, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Starter Solar Kit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Includes 2 panels, 1 inverter, and battery — perfect for small homes.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '\$799.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
