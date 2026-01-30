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
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
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
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined),
              selectedIcon: Icon(Icons.build),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authProvider.user?.name ?? 'Owner'}! 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your bike service station',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                authProvider.logout();
                                Navigator.pop(context);
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      value: pendingBookings.length.toString(),
                      color: AppTheme.warningColor,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_shipping,
                      title: 'Ready',
                      value: readyBookings.length.toString(),
                      color: AppTheme.successColor,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      title: 'Completed',
                      value: completedBookings.length.toString(),
                      color: AppTheme.primaryColor,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.build,
                      title: 'Services',
                      value: serviceProvider.services.length.toString(),
                      color: AppTheme.secondaryColor,
                      onTap: () => onNavigate(1),
                    ),
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigate(2),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (bookingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (pendingBookings.isEmpty)
                const EmptyState(
                  icon: Icons.inbox,
                  title: 'No pending bookings',
                  description: 'New bookings will appear here',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingBookings.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = pendingBookings[index];
                    return BookingCard(
                      bookingId: booking.id,
                      customerName: booking.customer.name,
                      customerEmail: booking.customer.email,
                      customerPhone: booking.customer.phone,
                      bookingDate: booking.bookingDate,
                      status: booking.statusDisplay,
                      totalPrice: booking.totalPrice,
                      services: booking.services.map((s) => s.serviceName).toList(),
                      onTap: () {
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
