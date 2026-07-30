import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _fareController = TextEditingController(text: '2500');

  late String _selectedPackageType;
  String _selectedWeightClass = 'Light (<5kg)';

  @override
  void initState() {
    super.initState();
    _selectedPackageType = widget.initialPackageType ?? 'Parcel';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _instructionsController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final authState = ref.read(authNotifierProvider);
    final customerUid = authState.user?.uid ?? '';
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
    notifier.createDeliveryRequest(
      pickupAddress: _pickupController.text.trim(),
      dropoffAddress: _dropoffController.text.trim(),
      packageType: _selectedPackageType,
      weightClass: _selectedWeightClass,
      instructions: _instructionsController.text.trim(),
      estimatedFare: offerFare,
      customerUid: customerUid,
    );

    context.push('/rider-matching');
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
                                hintText:
                                    'Enter pickup address (e.g. 24 KN 59 St)',
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
                                hintText: 'Enter drop-off destination',
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

                  // Customer Offered Price Input
                  Text('Offered Price (RWF)',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Enter the fare amount you wish to offer the rider',
                      style: AppTypography.bodySmall(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  AppTextField(
                    hintText: 'E.g. 2500',
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    suffixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('RWF',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Delivery Instructions
                  Text('Delivery Instructions (Optional)',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface)),
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
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
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
            Icon(icon,
                size: 28,
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.titleMedium(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
