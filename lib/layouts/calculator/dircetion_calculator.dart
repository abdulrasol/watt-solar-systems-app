import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DirectionCalculator extends StatefulWidget {
  const DirectionCalculator({super.key});

  @override
  State<DirectionCalculator> createState() => _DirectionCalculatorState();
}

class _DirectionCalculatorState extends State<DirectionCalculator> {
  bool isLocationGranted = false;
  double? latitude;
  double? azimuth;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // Request location permission and fetch current location.
  Future<void> getLocation() async {
    if (await Permission.location.request().isGranted) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = pos.latitude;
        isLocationGranted = true;
      });
    } else {
      setState(() {
        isLocationGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direction Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GetPlatform.isMobile
            ? isLocationGranted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Image.asset('assets/png/cards/direction.png',
                          height: 150),
                      const SizedBox(height: 20),
                      // Display the user's current latitude.
                      Text(
                        '📍 Your Latitude: ${latitude?.toStringAsFixed(4)}°',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      // Display the suggested tilt angle based on latitude.
                      Text(
                        '📐 Suggested Tilt Angle: ${latitude?.toStringAsFixed(1)}°',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      // StreamBuilder to handle real-time compass data.
                      StreamBuilder<CompassEvent>(
                        stream: FlutterCompass.events,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final direction = snapshot.data!.heading!;
                            return Column(
                              children: [
                                // Rotate the compass icon to the direction.
                                Transform.rotate(
                                  angle: -(direction + 180) * (math.pi / 180),
                                  child: Icon(Icons.navigation,
                                      size: 100, color: Colors.blueAccent),
                                ),
                                const SizedBox(height: 10),
                                // Display the azimuth value.
                                Text(
                                  '🧭 Azimuth: ${direction.toStringAsFixed(0)}°',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // Add explanations about azimuth and tilt angle.
                                const SizedBox(height: 20),
                                Text(
                                  '🔄 Azimuth is the angle between the North direction and your current direction. It helps in determining the proper orientation of solar panels.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '🌞 Tilt Angle is based on your latitude, which indicates the ideal angle for solar panel installation to capture the maximum sunlight throughout the year.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      '🔒 Location permission is required!',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
            : const Center(
                child: Text(
                  'On Mobile Only',
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}
