import 'dart:async';
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
  final bool isLiveMoving;

  const SimulatedMapWidget({
    super.key,
    this.riderLocations = const [],
    this.showRiderPins = true,
    this.showRadarScan = false,
    this.showRoute = false,
    this.centerLabel,
    this.pickupLocation,
    this.dropoffLocation,
    this.isLiveMoving = true,
  });

  @override
  State<SimulatedMapWidget> createState() => _SimulatedMapWidgetState();
}

class _SimulatedMapWidgetState extends State<SimulatedMapWidget> {
  Timer? _animTimer;
  double _progress = 0.2; // 0.0 to 1.0 along route
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    if (widget.isLiveMoving) {
      _startRiderMovement();
    }
  }

  void _startRiderMovement() {
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        if (_forward) {
          _progress += 0.008;
          if (_progress >= 0.85) _forward = false;
        } else {
          _progress -= 0.008;
          if (_progress <= 0.15) _forward = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  LatLng _interpolate(LatLng start, LatLng end, double fraction) {
    final lat = start.latitude + (end.latitude - start.latitude) * fraction;
    final lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
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

    // Calculate moving rider position along pickup -> dropoff polyline
    final movingRiderPos = _interpolate(effectivePickup, effectiveDropoff, _progress);

    final effectiveRiders = widget.riderLocations.isNotEmpty
        ? widget.riderLocations
        : (widget.showRiderPins
            ? [
                movingRiderPos,
                const LatLng(-1.9400, 30.0550),
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
                  if (widget.showRoute)
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

                  // Moving Rider Markers with explicit keys
                  for (int i = 0; i < effectiveRiders.length; i++)
                    Marker(
                      key: ValueKey('rider_${i}_${effectiveRiders[i].latitude}_${effectiveRiders[i].longitude}'),
                      point: effectiveRiders[i],
                      width: 42,
                      height: 42,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.accentOrange : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(
                          Icons.two_wheeler,
                          color: Colors.white,
                          size: 22,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

