import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SimulatedMapWidget extends StatelessWidget {
  final List<LatLng> riderLocations;
  final bool showRiderPins;
  final bool showRadarScan;
  final bool showRoute;
  final String? centerLabel;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;

  const SimulatedMapWidget({
    super.key,
    this.riderLocations = const [],
    this.showRiderPins = true,
    this.showRadarScan = false,
    this.showRoute = false,
    this.centerLabel,
    this.pickupLocation,
    this.dropoffLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Default Kigali Coordinates
    const kigaliCenter = LatLng(-1.9441, 30.0619); // Nyarugenge CBD
    const defaultPickupLoc = LatLng(-1.9536, 30.0917); // Kimihurura
    const defaultDropoffLoc = LatLng(-1.9612, 30.1250); // Remera

    final effectivePickup = pickupLocation ?? defaultPickupLoc;
    final effectiveDropoff = dropoffLocation ?? defaultDropoffLoc;
    final mapCenter = pickupLocation ?? kigaliCenter;

    // Use passed riderLocations, or fallback to default coordinates if showRiderPins is true and riderLocations is empty
    final effectiveRiders = riderLocations.isNotEmpty
        ? riderLocations
        : (showRiderPins
            ? const [
                LatLng(-1.9480, 30.0680),
                LatLng(-1.9400, 30.0550),
                LatLng(-1.9580, 30.0820),
              ]
            : <LatLng>[]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.gezayo_app',
                ),
                if (showRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          mapCenter,
                          effectivePickup,
                          effectiveDropoff,
                        ],
                        strokeWidth: 5.0,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Pickup Marker
                    Marker(
                      key: ValueKey('pickup_${effectivePickup.latitude}_${effectivePickup.longitude}'),
                      point: effectivePickup,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),

                    // Dropoff Marker
                    if (showRoute)
                      Marker(
                        key: ValueKey('dropoff_${effectiveDropoff.latitude}_${effectiveDropoff.longitude}'),
                        point: effectiveDropoff,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),

                    // Rider Markers with explicit keys to prevent mouse_tracker assertions on web
                    for (int i = 0; i < effectiveRiders.length; i++)
                      Marker(
                        key: ValueKey('rider_${i}_${effectiveRiders[i].latitude}_${effectiveRiders[i].longitude}'),
                        point: effectiveRiders[i],
                        width: 36,
                        height: 36,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.two_wheeler,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Center Location Header Badge
            if (centerLabel != null)
              Positioned(
                top: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        centerLabel!,
                        style: AppTypography.titleMedium(
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
  }
}
