import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ServicesTab(),
          MyBookingsScreen(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatefulWidget {
  const _ServicesTab();

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  final Set<String> _selectedServiceIds = {};

  double get _totalPrice {
    final serviceProvider = context.read<ServiceProvider>();
    return _selectedServiceIds.fold(0.0, (sum, id) {
      final service = serviceProvider.services.firstWhere(
        (s) => s.id == id,
        orElse: () => BikeService(
          id: '',
          name: '',
          price: 0,
          estimatedTime: 0,
          estimatedTimeDisplay: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return sum + service.price;
    });
  }

  void _toggleService(String serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  void _proceedToBooking() {
    if (_selectedServiceIds.isEmpty) {
      showSnackbar(context, 'Please select at least one service', isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          selectedServiceIds: _selectedServiceIds.toList(),
        ),
      ),
    ).then((booked) {
      if (booked == true) {
        setState(() => _selectedServiceIds.clear());
        showSnackbar(context, 'Booking created successfully!', isSuccess: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${authProvider.user?.name ?? 'there'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select services to book',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        color: AppTheme.primaryForeground,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => serviceProvider.loadServices(),
              child: serviceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : serviceProvider.services.isEmpty
                      ? const EmptyState(
                          icon: Icons.build_outlined,
                          title: 'No services available',
                          description: 'Check back later for available services',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? size.width * 0.15 : 16,
                            vertical: 8,
                          ),
                          itemCount: serviceProvider.services.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final service = serviceProvider.services[index];
                            return ServiceAccordionCard(
                              name: service.name,
                              description: service.description,
                              price: service.price,
                              estimatedTime: service.estimatedTimeDisplay,
                              isSelected: _selectedServiceIds.contains(service.id),
                              onTap: () => _toggleService(service.id),
                            );
                          },
                        ),
            ),
          ),

          // Bottom CTA
          if (_selectedServiceIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_selectedServiceIds.length} service${_selectedServiceIds.length > 1 ? 's' : ''} selected',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          Text(
                            '\$${_totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ShadcnButton(
                      text: 'Continue',
                      icon: Icons.arrow_forward,
                      onPressed: _proceedToBooking,
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? size.width * 0.2 : 16,
          vertical: 24,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground,
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),

            // Account Options
            ShadcnAccordion(
              title: 'Account Settings',
              leadingIcon: Icons.settings_outlined,
              content: Column(
                children: [
                  _SettingItem(icon: Icons.person_outline, title: 'Edit Profile'),
                  _SettingItem(icon: Icons.notifications_outlined, title: 'Notifications'),
                  _SettingItem(icon: Icons.lock_outline, title: 'Change Password'),
                ],
              ),
            ),
            ShadcnAccordion(
              title: 'Support',
              leadingIcon: Icons.help_outline,
              content: Column(
                children: [
                  _SettingItem(icon: Icons.chat_bubble_outline, title: 'Contact Us'),
                  _SettingItem(icon: Icons.description_outlined, title: 'Terms of Service'),
                  _SettingItem(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Logout
            ShadcnButton(
              text: 'Sign out',
              isOutlined: true,
              isDestructive: true,
              width: double.infinity,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          authProvider.logout();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Sign out', style: TextStyle(color: AppTheme.destructive)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: AppTheme.mutedForeground),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.mutedForeground),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
