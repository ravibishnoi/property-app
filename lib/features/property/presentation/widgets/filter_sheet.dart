import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/property_filter.dart';
import '../providers/property_providers.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late PropertyType? _selectedType;
  late PropertyStatus? _selectedStatus;
  late String? _selectedConfig;
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  late TextEditingController _locationController;

  static const double minPrice = 2000000; // 20 Lakhs
  static const double maxPrice = 20000000; // 2 Crores
  static const double minArea = 500;
  static const double maxArea = 5000;

  @override
  void initState() {
    super.initState();
    final current = ref.read(propertyFilterProvider);
    _selectedType = current.type;
    _selectedStatus = current.status;
    _selectedConfig = current.configuration;
    _priceRange = current.priceRange ?? const RangeValues(minPrice, maxPrice);
    _areaRange = current.areaRange ?? const RangeValues(minArea, maxArea);
    _locationController = TextEditingController(text: current.location ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final updated = PropertyFilter(
      keyword: ref.read(propertyFilterProvider).keyword,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      configuration: _selectedConfig,
      priceRange: (_priceRange.start > minPrice || _priceRange.end < maxPrice)
          ? _priceRange
          : null,
      areaRange: (_areaRange.start > minArea || _areaRange.end < maxArea)
          ? _areaRange
          : null,
    );
    ref.read(propertyFilterProvider.notifier).updateFilter(updated);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedConfig = null;
      _priceRange = const RangeValues(minPrice, maxPrice);
      _areaRange = const RangeValues(minArea, maxArea);
      _locationController.clear();
    });
    ref.read(propertyFilterProvider.notifier).resetFilter();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(isDark ? 0.3 : 0.6),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Filter Properties',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset All'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable filter contents
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Location field
                  Text(
                    'Location / Locality',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Vaishali Nagar, Mansarovar',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      suffixIcon: _locationController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _locationController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Property Type chips
                  Text(
                    'Property Type',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'All Types',
                        isSelected: _selectedType == null,
                        onSelected: (selected) {
                          setState(() => _selectedType = null);
                        },
                      ),
                      ...PropertyType.values.map(
                        (type) => _buildChoiceChip(
                          label: type.label,
                          isSelected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Range Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price Range',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${AppConstants.formatCurrency(_priceRange.start)} - ${AppConstants.formatCurrency(_priceRange.end)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: minPrice,
                    max: maxPrice,
                    divisions: 36,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.15),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Area Range Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Area Range (sqft)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_areaRange.start.round()} - ${_areaRange.end.round()} sqft',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _areaRange,
                    min: minArea,
                    max: maxArea,
                    divisions: 45,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.15),
                    onChanged: (values) {
                      setState(() => _areaRange = values);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bedrooms / Configuration
                  Text(
                    'Configuration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'Any',
                        isSelected: _selectedConfig == null,
                        onSelected: (selected) {
                          setState(() => _selectedConfig = null);
                        },
                      ),
                      ...['1BHK', '2BHK', '3BHK', '4BHK', '5BHK'].map(
                        (cfg) => _buildChoiceChip(
                          label: cfg,
                          isSelected: _selectedConfig == cfg,
                          onSelected: (selected) {
                            setState(() {
                              _selectedConfig = selected ? cfg : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status
                  Text(
                    'Availability Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'All Statuses',
                        isSelected: _selectedStatus == null,
                        onSelected: (selected) {
                          setState(() => _selectedStatus = null);
                        },
                      ),
                      ...PropertyStatus.values.map(
                        (status) => _buildChoiceChip(
                          label: status.label,
                          isSelected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : theme.colorScheme.onSurface.withOpacity(0.8),
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.4),
          width: 1,
        ),
      ),
    );
  }
}
