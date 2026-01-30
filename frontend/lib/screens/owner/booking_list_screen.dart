import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BookingStatus? _selectedFilter;

  final List<({String label, BookingStatus? status})> _filters = [
    (label: 'All', status: null),
    (label: 'Pending', status: BookingStatus.pending),
    (label: 'In Progress', status: BookingStatus.inProgress),
    (label: 'Ready', status: BookingStatus.readyForDelivery),
    (label: 'Completed', status: BookingStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedFilter = _filters[_tabController.index].status;
      });
      context.read<BookingProvider>().loadBookings(status: _selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: _filters.map((f) => Tab(text: f.label)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingProvider.loadBookings(status: _selectedFilter),
        child: bookingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookingProvider.bookings.isEmpty
                ? const EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No bookings found',
                    description: 'Bookings will appear here when customers book services',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.bookings[index];
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
                          ).then((_) {
                            bookingProvider.loadBookings(status: _selectedFilter);
                          });
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
