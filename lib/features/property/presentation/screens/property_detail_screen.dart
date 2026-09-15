import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/property_providers.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower == 'available') return AppColors.statusAvailable;
    if (lower == 'sold') return AppColors.statusSold;
    return AppColors.statusPending;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detailAsync = ref.watch(propertyDetailProvider(propertyId));

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          if (detail == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.home_work_outlined,
                title: 'Property Not Found',
                message: 'This property listing could not be found.',
              ),
            );
          }

          final property = detail.property;
          final owner = detail.owner;
          final statusColor = _getStatusColor(property.status);

          final currentUser = ref.watch(authProvider).value;
          final isOwner = currentUser?.isOwner ?? false;
          final isOwnListing = isOwner && (currentUser?.id == property.ownerId);

          return Stack(
            children: [
              // Scrollable content
              CustomScrollView(
                slivers: [
                  // Hero Image Header
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Saved to your shortlisted properties!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            property.imagePlaceholder,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                child: const Center(
                                  child: Icon(Icons.apartment_rounded, size: 64),
                                ),
                              );
                            },
                          ),
                          // Scrim
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                          // Badges overlay at bottom of image
                          Positioned(
                            bottom: 16,
                            left: 20,
                            right: 20,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white24,
                                    ),
                                  ),
                                  child: Text(
                                    property.type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.6),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        property.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Property Body Info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price & Full price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                AppConstants.formatCurrency(property.price),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '(${AppConstants.formatFullPrice(property.price)})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Property Name
                          Text(
                            property.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Location with map pin
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Key Specs Grid
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                    isDark ? 0.3 : 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSpecColumn(
                                  context: context,
                                  icon: Icons.king_bed_outlined,
                                  value: property.configuration,
                                  label: 'Bedrooms',
                                ),
                                _buildVerticalDivider(context),
                                _buildSpecColumn(
                                  context: context,
                                  icon: Icons.straighten_rounded,
                                  value: '${property.area}',
                                  label: property.areaUnit,
                                ),
                                _buildVerticalDivider(context),
                                _buildSpecColumn(
                                  context: context,
                                  icon: Icons.currency_rupee_rounded,
                                  value: '₹${property.pricePerSqft}',
                                  label: 'Per sqft',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'About this Property',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            property.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Property Owner Card
                          Text(
                            'Property Listed By',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                    isDark ? 0.3 : 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: theme.colorScheme.secondary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            owner?['name'] ?? 'Property Owner',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.verified_rounded,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          if (isOwnListing) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'You',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        owner?['contact'] ?? 'Verified Owner',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Fixed Bottom Submit Interest Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(isDark ? 0.3 : 0.5),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              AppConstants.formatCurrency(property.price),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: isOwnListing
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/owner-dashboard');
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.business_center_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Your Listing • View Inquiries'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                              : isOwner
                                  ? ElevatedButton.icon(
                                      onPressed: null,
                                      icon: const Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Owner View Only'),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: property.isSold
                                          ? null
                                          : () {
                                              context.push(
                                                '/interest/${property.id}',
                                                extra: property.name,
                                              );
                                            },
                                      icon: Icon(
                                        property.isSold
                                            ? Icons.lock_outline_rounded
                                            : Icons.send_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        property.isSold
                                            ? 'Sold Out'
                                            : 'Submit Interest',
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error Loading Property',
            message: err.toString(),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecColumn({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
    );
  }
}
