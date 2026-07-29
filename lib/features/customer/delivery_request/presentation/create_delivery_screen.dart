import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../presentation/delivery_notifier.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  final String? initialPackageType;

  const CreateDeliveryScreen({super.key, this.initialPackageType});

  @override
  ConsumerState<CreateDeliveryScreen> createState() =>
      _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  final _pickupController =
      TextEditingController(text: '24 KN 59 St, Kigali (Your Location)');
  final _dropoffController =
      TextEditingController(text: 'Mamba Club, Kimihurura');
  final _instructionsController = TextEditingController();

  late String _selectedPackageType;
  String _selectedWeightClass = 'Light (<5kg)';
  final double _estimatedFare = 2500;

  @override
  void initState() {
    super.initState();
    _selectedPackageType = widget.initialPackageType ?? 'Parcel';
  }

  void _submitRequest() {
    final notifier = ref.read(deliveryNotifierProvider.notifier);
    notifier.createDeliveryRequest(
      pickupAddress: _pickupController.text,
      dropoffAddress: _dropoffController.text,
      packageType: _selectedPackageType,
      weightClass: _selectedWeightClass,
      instructions: _instructionsController.text,
      estimatedFare: _estimatedFare,
    );

    context.push('/rider-matching');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('New Delivery', style: AppTypography.headlineMedium()),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryMint,
              child: Text('J', style: TextStyle(color: AppColors.primary)),
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
                        showRiderPins: false,
                        showRoute: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Locations Input Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
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
                                hintText: 'Where to pick up?',
                                controller: _pickupController,
                                suffixIcon: const Icon(Icons.my_location,
                                    color: AppColors.primary),
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
                                hintText: 'Where is it going?',
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
                          style: AppTypography.headlineMedium()),
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
                  Text('Weight Class', style: AppTypography.headlineMedium()),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _WeightPill(
                          label: 'Light (<5kg)',
                          isSelected: _selectedWeightClass == 'Light (<5kg)',
                          onTap: () => setState(
                              () => _selectedWeightClass = 'Light (<5kg)'),
                        ),
                        const SizedBox(width: 8),
                        _WeightPill(
                          label: 'Medium (5-15kg)',
                          isSelected: _selectedWeightClass == 'Medium (5-15kg)',
                          onTap: () => setState(
                              () => _selectedWeightClass = 'Medium (5-15kg)'),
                        ),
                        const SizedBox(width: 8),
                        _WeightPill(
                          label: 'Heavy (>15kg)',
                          isSelected: _selectedWeightClass == 'Heavy (>15kg)',
                          onTap: () => setState(
                              () => _selectedWeightClass = 'Heavy (>15kg)'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Delivery Instructions
                  Text('Delivery Instructions (Optional)',
                      style: AppTypography.headlineMedium()),
                  const SizedBox(height: 12),
                  AppTextField(
                    hintText: 'E.g. Ring doorbell at gate, fragile item...',
                    controller: _instructionsController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Fare Summary & Request CTA Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
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
                        Text('Estimated Total',
                            style: AppTypography.bodySmall(
                                color: AppColors.textSecondary)),
                        Text('RWF ${_estimatedFare.toStringAsFixed(0)}',
                            style: AppTypography.headlineLarge(
                                color: AppColors.textPrimary)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 28,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.titleMedium(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeightPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.titleMedium(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
