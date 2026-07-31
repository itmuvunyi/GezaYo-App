import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../presentation/delivery_notifier.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  final String? initialPackageType;

  const CreateDeliveryScreen({super.key, this.initialPackageType});

  @override
  ConsumerState<CreateDeliveryScreen> createState() =>
      _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState
    extends ConsumerState<CreateDeliveryScreen> {
  final _pickupController = TextEditingController(text: '');
  final _dropoffController =
      TextEditingController(text: '');
  final _instructionsController = TextEditingController();
  final _fareController = TextEditingController(text: '');

  String _selectedPackageType = 'Parcel';
  String _selectedWeightClass = 'Light (<5kg)';

  @override
  void initState() {
    super.initState();
    if (widget.initialPackageType != null &&
        widget.initialPackageType!.isNotEmpty) {
      final raw = widget.initialPackageType!;
      _selectedPackageType =
          raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      if (kIsWeb) {
        setState(() {
          _pickupController.text = '24 KN 59 St, Nyarugenge, Kigali';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS Location updated: Kigali CBD')),
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location services are disabled on this device.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Location permissions are permanently denied.')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _pickupController.text =
            'Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'GPS Location detected: (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})'),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      debugPrint('Location fetch error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching GPS location: $e')),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    final authState = ref.read(authNotifierProvider);
    final customerUid = authState.user?.uid ?? 'usr-customer-101';
    final customerPhone = authState.user?.phoneNumber ?? '';
    final offerFare = double.tryParse(_fareController.text.trim()) ?? 2500.0;

    if (_pickupController.text.trim().isEmpty ||
        _dropoffController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter pickup and drop-off addresses.')),
      );
      return;
    }

    final notifier = ref.read(deliveryNotifierProvider.notifier);
    await notifier.createDeliveryRequest(
      pickupAddress: _pickupController.text.trim(),
      dropoffAddress: _dropoffController.text.trim(),
      packageType: _selectedPackageType,
      weightClass: _selectedWeightClass,
      instructions: _instructionsController.text.trim(),
      estimatedFare: offerFare,
      customerUid: customerUid,
      customerPhone: customerPhone,
    );

    if (mounted) {
      context.push('/rider-matching');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('New Delivery',
            style: AppTypography.headlineMedium(
                color: theme.colorScheme.onSurface)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryMint,
              child: Icon(Icons.person, size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Preview Card
                  SizedBox(
                    height: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: const SimulatedMapWidget(
                        showRoute: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Locations Input Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        // Pickup Location Row
                        Row(
                          children: [
                            const Icon(Icons.radio_button_checked,
                                color: AppColors.statusSuccess, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Pickup Location',
                                hintText: '24 KN 59 St, Kigali',
                                controller: _pickupController,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.my_location,
                                      color: AppColors.primary),
                                  onPressed: _fetchCurrentLocation,
                                ),
                              ),
                            ),
                          ],
                        ),


                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 20,
                              child: VerticalDivider(
                                color: AppColors.cardBorder,
                                thickness: 2,
                              ),
                            ),
                          ),
                        ),

                        // Dropoff Location Row
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.accentOrange, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Drop-off Location',
                                hintText: 'Kimironko, Zindiro',
                                controller: _dropoffController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Package Type Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Package Type',
                          style: AppTypography.headlineMedium(
                              color: theme.colorScheme.onSurface)),
                      Text('Required',
                          style: AppTypography.labelMedium(
                              color: AppColors.statusSuccess)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Package Type Selection Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _PackageOptionCard(
                        title: 'Food',
                        icon: Icons.restaurant,
                        isSelected: _selectedPackageType == 'Food',
                        onTap: () =>
                            setState(() => _selectedPackageType = 'Food'),
                      ),
                      _PackageOptionCard(
                        title: 'Parcel',
                        icon: Icons.inventory_2,
                        isSelected: _selectedPackageType == 'Parcel',
                        onTap: () =>
                            setState(() => _selectedPackageType = 'Parcel'),
                      ),
                      _PackageOptionCard(
                        title: 'Grocery',
                        icon: Icons.shopping_basket,
                        isSelected: _selectedPackageType == 'Grocery',
                        onTap: () =>
                            setState(() => _selectedPackageType = 'Grocery'),
                      ),
                      _PackageOptionCard(
                        title: 'Other',
                        icon: Icons.more_horiz,
                        isSelected: _selectedPackageType == 'Other',
                        onTap: () =>
                            setState(() => _selectedPackageType = 'Other'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Weight Class Section
                  Text('Weight Class',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Light (<5kg)',
                        'Medium (5-15kg)',
                        'Heavy (>15kg)'
                      ].map((w) {
                        final isSelected = _selectedWeightClass == w;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(w),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedWeightClass = w);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Custom Fare Offer Input Section
                  Text('Offer Your Price (RWF)',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Enter the fare you are offering for this delivery:',
                      style: AppTypography.bodySmall(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 10),

                  AppTextField(
                    label: 'Offered Delivery Fare (RWF)',
                    hintText: 'e.g. 2500',
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Delivery Instructions Input Card
                  Text('Delivery Instructions (Optional)',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: 'Special Instructions',
                    hintText:
                        'e.g. Leave with security guard, fragile package...',
                    controller: _instructionsController,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Fare & Confirm Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                  top: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Offered Price',
                            style: AppTypography.bodySmall(
                                color: theme.colorScheme.onSurfaceVariant)),
                        Text(
                          'RWF ${_fareController.text.trim().isEmpty ? '0' : _fareController.text.trim()}',
                          style: AppTypography.headlineLarge(
                              color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bolt,
                            color: AppColors.statusSuccess, size: 18),
                        Text('Fastest',
                            style: AppTypography.titleMedium(
                                color: AppColors.statusSuccess)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Request Rider',
                  icon: Icons.arrow_forward_ios,
                  onPressed: _submitRequest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageOptionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color:
                  isSelected ? AppColors.primary : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.titleMedium(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
