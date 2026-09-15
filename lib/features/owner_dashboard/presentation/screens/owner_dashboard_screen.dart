import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:property_app/core/theme/app_theme.dart';
import 'package:property_app/core/widgets/empty_state.dart';
import 'package:property_app/core/widgets/property_card.dart';
import 'package:property_app/core/widgets/theme_toggle_button.dart';
import 'package:property_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:property_app/features/interest/domain/entities/interest_submission.dart';
import 'package:property_app/features/interest/presentation/providers/interest_providers.dart';
import 'package:property_app/features/property/presentation/providers/property_providers.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authProvider).value;
    final ownerId = user?.id ?? '';

    final propertiesAsync = ref.watch(ownerPropertiesProvider(ownerId));
    final interestsAsync = ref.watch(ownerInterestsProvider(ownerId));

    final totalProperties = propertiesAsync.value?.length ?? 0;
    final availableProperties = propertiesAsync.value
            ?.where((p) => p.isAvailable)
            .length ??
        0;
    final totalInquiries = interestsAsync.value?.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Top Owner Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.business_center_rounded,
                          color: theme.colorScheme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Owner Portal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.name ?? 'Property Owner',
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

              // KPI Summary Metrics
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'My Listings',
                          count: '$totalProperties',
                          icon: Icons.holiday_village_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Available',
                          count: '$availableProperties',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.statusAvailable,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Inquiries',
                          count: '$totalInquiries',
                          icon: Icons.mark_email_unread_outlined,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(
                          isDark ? 0.3 : 0.6),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: isDark ? Colors.black : Colors.white,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withOpacity(0.7),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.maps_home_work_outlined, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Properties ($totalProperties)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mail_outline_rounded, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Inquiries ($totalInquiries)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Owner's Properties
              _buildPropertiesTab(propertiesAsync),

              // Tab 2: Received Inquiries
              _buildInterestsTab(interestsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(isDark ? 0.3 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab(AsyncValue propertiesAsync) {
    return propertiesAsync.when(
      data: (properties) {
        if (properties.isEmpty) {
          return const EmptyState(
            icon: Icons.maps_home_work_outlined,
            title: 'No Listed Properties',
            message: 'You currently have no properties assigned under this account.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: PropertyCard(
                property: property,
                onTap: () => context.push('/property/${property.id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error Loading Properties',
        message: err.toString(),
      ),
    );
  }

  Widget _buildInterestsTab(AsyncValue<List<InterestSubmission>> interestsAsync) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return interestsAsync.when(
      data: (interests) {
        if (interests.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'No Inquiries Yet',
            message:
                'When potential buyers submit interest in your properties, they will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          itemCount: interests.length,
          itemBuilder: (context, index) {
            final item = interests[index];
            final formattedDate =
                DateFormat('MMM d, yyyy • h:mm a').format(item.submittedAt);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(
                      isDark ? 0.3 : 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Tag & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.apartment_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.propertyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Applicant Name
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Phone & Email with Copy action
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: item.mobile));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number copied to clipboard!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 15,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+91 ${item.mobile}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: item.email));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email copied to clipboard!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 15,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.email,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Message Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF162032)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error Loading Inquiries',
        message: err.toString(),
      ),
    );
  }
}
