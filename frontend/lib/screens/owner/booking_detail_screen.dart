import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().getBooking(widget.bookingId);
    });
  }

  void _updateStatus(BookingStatus newStatus) async {
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.updateBookingStatus(
      id: widget.bookingId,
      status: newStatus,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.displayName}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted && bookingProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.currentBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const EmptyState(
                  icon: Icons.error_outline,
                  title: 'Booking not found',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: _getStatusGradient(booking.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getStatusIcon(booking.status),
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              booking.statusDisplay,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#${booking.id.substring(0, 8)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Customer Info
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Name',
                            value: booking.customer.name,
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: booking.customer.email,
                          ),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: booking.customer.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Booking Info
                      const Text(
                        'Booking Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value:
                                '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                          ),
                          _InfoRow(
                            icon: Icons.access_time,
                            label: 'Created',
                            value:
                                '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                          ),
                          if (booking.notes != null && booking.notes!.isNotEmpty)
                            _InfoRow(
                              icon: Icons.notes,
                              label: 'Notes',
                              value: booking.notes!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Services
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          children: [
                            ...booking.services.map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      s.serviceName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '\$${s.servicePrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Status Actions
                      if (booking.status != BookingStatus.completed &&
                          booking.status != BookingStatus.cancelled) ...[
                        const Text(
                          'Update Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _getAvailableStatusActions(booking.status)
                              .map(
                                (status) => ElevatedButton.icon(
                                  onPressed: () => _updateStatus(status),
                                  icon: Icon(_getStatusIcon(status)),
                                  label: Text(status.displayName),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getStatusColor(status),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  LinearGradient _getStatusGradient(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case BookingStatus.confirmed:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case BookingStatus.inProgress:
        return AppTheme.primaryGradient;
      case BookingStatus.readyForDelivery:
        return AppTheme.successGradient;
      case BookingStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
        );
      case BookingStatus.cancelled:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.warningColor;
      case BookingStatus.confirmed:
        return AppTheme.infoColor;
      case BookingStatus.inProgress:
        return AppTheme.primaryColor;
      case BookingStatus.readyForDelivery:
        return AppTheme.successColor;
      case BookingStatus.completed:
        return Colors.green.shade700;
      case BookingStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending_actions;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.build;
      case BookingStatus.readyForDelivery:
        return Icons.local_shipping;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  List<BookingStatus> _getAvailableStatusActions(BookingStatus current) {
    switch (current) {
      case BookingStatus.pending:
        return [BookingStatus.confirmed, BookingStatus.cancelled];
      case BookingStatus.confirmed:
        return [BookingStatus.inProgress, BookingStatus.cancelled];
      case BookingStatus.inProgress:
        return [BookingStatus.readyForDelivery];
      case BookingStatus.readyForDelivery:
        return [BookingStatus.completed];
      default:
        return [];
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
