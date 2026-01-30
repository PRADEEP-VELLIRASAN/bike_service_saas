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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Bookings',
          style: TextStyle(
            color: AppTheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.foreground,
              indicatorWeight: 2,
              labelColor: AppTheme.foreground,
              unselectedLabelColor: AppTheme.mutedForeground,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              tabs: _filters.map((f) => Tab(text: f.label)).toList(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingProvider.loadBookings(status: _selectedFilter),
        color: AppTheme.primary,
        child: bookingProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              )
            : bookingProvider.bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.muted,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 32,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No bookings found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bookings will appear here when customers book services',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.bookings[index];
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
