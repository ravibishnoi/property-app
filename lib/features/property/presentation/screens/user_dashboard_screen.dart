import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/property_providers.dart';
import '../widgets/filter_sheet.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(propertyFilterProvider);
    if (filter.keyword != null) {
      _searchController.text = filter.keyword!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(propertyFilterProvider.notifier).setKeyword(value.trim().isEmpty ? null : value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).value;
    final propertiesAsync = ref.watch(propertyListProvider);
    final filter = ref.watch(propertyFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Text(
                        (user?.name.isNotEmpty ?? false)
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            user?.name ?? 'Guest User',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ThemeToggleButton(isCompact: true),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 22),
                      tooltip: 'Logout',
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search city, project, area...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 22),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Badge(
                      isLabelVisible: filter.hasActiveFilters,
                      label: Text('${filter.activeFilterCount}'),
                      backgroundColor: theme.colorScheme.secondary,
                      child: IconButton.filledTonal(
                        onPressed: () => FilterSheet.show(context),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(52, 52),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Quick Filter Chips for Property Types
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildQuickTypeChip(
                      label: 'All Properties',
                      isSelected: filter.type == null,
                      onTap: () =>
                          ref.read(propertyFilterProvider.notifier).setType(null),
                    ),
                    const SizedBox(width: 8),
                    ...PropertyType.values.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildQuickTypeChip(
                          label: type.label,
                          isSelected: filter.type == type,
                          onTap: () =>
                              ref.read(propertyFilterProvider.notifier).setType(
                                    filter.type == type ? null : type,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Listing Header with Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Listings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    propertiesAsync.when(
                      data: (list) => Text(
                        '${list.length} ${list.length == 1 ? "Property" : "Properties"}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Properties List / Grid
            propertiesAsync.when(
              data: (properties) {
                if (properties.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No Properties Found',
                      message:
                          'We couldn\'t find any properties matching your current search or filter criteria.',
                      actionLabel: 'Reset All Filters',
                      onAction: () {
                        _searchController.clear();
                        ref.read(propertyFilterProvider.notifier).resetFilter();
                      },
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final isTabletOrWeb = constraints.crossAxisExtent > 640;
                      if (isTabletOrWeb) {
                        return SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final property = properties[index];
                              return PropertyCard(
                                property: property,
                                onTap: () =>
                                    context.push('/property/${property.id}'),
                              );
                            },
                            childCount: properties.length,
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = properties[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: PropertyCard(
                                property: property,
                                onTap: () =>
                                    context.push('/property/${property.id}'),
                              ),
                            );
                          },
                          childCount: properties.length,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Properties',
                  message: err.toString(),
                  actionLabel: 'Try Again',
                  onAction: () => ref.invalidate(propertyListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(isDark ? 0.3 : 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
