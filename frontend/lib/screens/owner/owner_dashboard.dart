import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'service_management_screen.dart';
import 'booking_list_screen.dart';
import 'booking_detail_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final serviceProvider = context.read<ServiceProvider>();
    final bookingProvider = context.read<BookingProvider>();
    await Future.wait([
      serviceProvider.loadServices(activeOnly: false),
      bookingProvider.loadBookings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardHome(onNavigate: (index) => setState(() => _currentIndex = index)),
          const ServiceManagementScreen(),
          const BookingListScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppTheme.accent.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppTheme.mutedForeground),
              selectedIcon: Icon(Icons.dashboard, color: AppTheme.accent),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined, color: AppTheme.mutedForeground),
              selectedIcon: Icon(Icons.build, color: AppTheme.accent),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: AppTheme.mutedForeground),
              selectedIcon: Icon(Icons.calendar_today, color: AppTheme.accent),
              label: 'Bookings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final Function(int) onNavigate;

  const _DashboardHome({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final pendingBookings = bookingProvider.getBookingsByStatus(BookingStatus.pending);
    final readyBookings = bookingProvider.getBookingsByStatus(BookingStatus.readyForDelivery);
    final completedBookings = bookingProvider.getBookingsByStatus(BookingStatus.completed);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            serviceProvider.loadServices(activeOnly: false),
            bookingProvider.loadBookings(),
          ]);
        },
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.name ?? 'Owner',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ShadcnButton(
                    icon: Icons.logout,
                    variant: ShadcnButtonVariant.ghost,
                    size: ShadcnButtonSize.icon,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            side: const BorderSide(color: AppTheme.border),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: AppTheme.foreground),
                          ),
                          content: const Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(color: AppTheme.mutedForeground),
                          ),
                          actions: [
                            ShadcnButton(
                              text: 'Cancel',
                              variant: ShadcnButtonVariant.outline,
                              onPressed: () => Navigator.pop(context),
                            ),
                            ShadcnButton(
                              text: 'Logout',
                              variant: ShadcnButtonVariant.destructive,
                              onPressed: () {
                                authProvider.logout();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    icon: Icons.pending_actions,
                    title: 'Pending',
                    value: pendingBookings.length.toString(),
                    color: const Color(0xFFF59E0B),
                    onTap: () => onNavigate(2),
                  ),
                  _StatCard(
                    icon: Icons.local_shipping,
                    title: 'Ready',
                    value: readyBookings.length.toString(),
                    color: const Color(0xFF10B981),
                    onTap: () => onNavigate(2),
                  ),
                  _StatCard(
                    icon: Icons.check_circle,
                    title: 'Completed',
                    value: completedBookings.length.toString(),
                    color: AppTheme.primary,
                    onTap: () => onNavigate(2),
                  ),
                  _StatCard(
                    icon: Icons.build,
                    title: 'Services',
                    value: serviceProvider.services.length.toString(),
                    color: const Color(0xFF8B5CF6),
                    onTap: () => onNavigate(1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Pending Bookings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                  ShadcnButton(
                    text: 'View All',
                    variant: ShadcnButtonVariant.ghost,
                    size: ShadcnButtonSize.sm,
                    onPressed: () => onNavigate(2),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (bookingProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (pendingBookings.isEmpty)
                ShadcnCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No pending bookings',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'New bookings will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingBookings.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = pendingBookings[index];
                    return BookingAccordionCard(
                      bookingId: booking.id,
                      customerName: booking.customer.name,
                      customerEmail: booking.customer.email,
                      customerPhone: booking.customer.phone,
                      bookingDate: booking.bookingDate,
                      status: booking.statusDisplay,
                      totalPrice: booking.totalPrice,
                      services: booking.services.map((s) => s.serviceName).toList(),
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailScreen(bookingId: booking.id),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.mutedForeground,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.foreground,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
