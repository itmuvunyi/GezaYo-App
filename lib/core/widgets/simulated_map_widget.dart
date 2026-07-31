import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SimulatedMapWidget extends StatefulWidget {
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
  State<SimulatedMapWidget> createState() => _SimulatedMapWidgetState();
}

class _SimulatedMapWidgetState extends State<SimulatedMapWidget> {
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    if (widget.showRoute) {
      _fetchOsmRoute();
    }
  }

  @override
  void didUpdateWidget(covariant SimulatedMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showRoute &&
        (widget.pickupLocation != oldWidget.pickupLocation ||
            widget.dropoffLocation != oldWidget.dropoffLocation)) {
      _fetchOsmRoute();
    }
  }

  Future<void> _fetchOsmRoute() async {
    const defaultPickupLoc = LatLng(-1.9536, 30.0917);
    const defaultDropoffLoc = LatLng(-1.9612, 30.1250);

    final start = widget.pickupLocation ?? defaultPickupLoc;
    final end = widget.dropoffLocation ?? defaultDropoffLoc;

    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coordinates =
              routes[0]['geometry']['coordinates'] as List?;
          if (coordinates != null) {
            final points = coordinates.map((c) {
              final list = c as List;
              return LatLng(list[1].toDouble(), list[0].toDouble());
            }).toList();

            if (mounted && points.isNotEmpty) {
              setState(() {
                _routePoints = points;
              });
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM Route fetch error: $e');
    }

    if (mounted) {
      setState(() {
        _routePoints = [
          start,
          LatLng(
              start.latitude + (end.latitude - start.latitude) * 0.33 + 0.002,
              start.longitude + (end.longitude - start.longitude) * 0.33),
          LatLng(
              start.latitude + (end.latitude - start.latitude) * 0.66 - 0.002,
              start.longitude + (end.longitude - start.longitude) * 0.66),
          end,
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default Kigali Coordinates
    const kigaliCenter = LatLng(-1.9441, 30.0619); // Nyarugenge CBD
    const defaultPickupLoc = LatLng(-1.9536, 30.0917); // Kimihurura
    const defaultDropoffLoc = LatLng(-1.9612, 30.1250); // Remera

    final effectivePickup = widget.pickupLocation ?? defaultPickupLoc;
    final effectiveDropoff = widget.dropoffLocation ?? defaultDropoffLoc;
    final mapCenter = widget.pickupLocation ?? kigaliCenter;

    final polylinePoints = _routePoints.isNotEmpty
        ? _routePoints
        : [effectivePickup, effectiveDropoff];

    final effectiveRiders = widget.riderLocations.isNotEmpty
        ? widget.riderLocations
        : (widget.showRiderPins
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
              if (widget.showRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 5.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Pickup Marker
                  Marker(
                    key: ValueKey(
                        'pickup_${effectivePickup.latitude}_${effectivePickup.longitude}'),
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
                  if (widget.showRoute)
                    Marker(
                      key: ValueKey(
                          'dropoff_${effectiveDropoff.latitude}_${effectiveDropoff.longitude}'),
                      point: effectiveDropoff,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),

                  // Rider Markers
                  for (int i = 0; i < effectiveRiders.length; i++)
                    Marker(
                      key: ValueKey(
                          'rider_${i}_${effectiveRiders[i].latitude}_${effectiveRiders[i].longitude}'),
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
          if (widget.centerLabel != null)
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
                      widget.centerLabel!,
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

