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
      showSuccessSnackbar(context, 'Status updated to ${newStatus.displayName}');
    } else if (mounted && bookingProvider.error != null) {
      showErrorSnackbar(context, bookingProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.currentBooking;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: AppTheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bookingProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            )
          : booking == null
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
                          Icons.error_outline,
                          size: 32,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking not found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      ShadcnCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Icon(
                                _getStatusIcon(booking.status),
                                color: _getStatusColor(booking.status),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            StatusBadge(
                              status: booking.statusDisplay,
                              color: _getStatusColor(booking.status),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '#${booking.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.mutedForeground,
                                fontFamily: 'monospace',
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShadcnCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Name',
                              value: booking.customer.name,
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: booking.customer.email,
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: booking.customer.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Booking Info
                      const Text(
                        'Booking Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShadcnCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Booking Date',
                              value:
                                  '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Created',
                              value:
                                  '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                            ),
                            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                              const Divider(color: AppTheme.border, height: 24),
                              _InfoRow(
                                icon: Icons.notes,
                                label: 'Notes',
                                value: booking.notes!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Services
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShadcnCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...booking.services.asMap().entries.map(
                              (entry) => Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.value.serviceName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.foreground,
                                          ),
                                        ),
                                        Text(
                                          '\$${entry.value.servicePrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.foreground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (entry.key < booking.services.length - 1)
                                    const Divider(color: AppTheme.border, height: 16),
                                ],
                              ),
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.foreground,
                                  ),
                                ),
                                Text(
                                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _getAvailableStatusActions(booking.status)
                              .map(
                                (status) => ShadcnButton(
                                  text: status.displayName,
                                  icon: _getStatusIcon(status),
                                  variant: status == BookingStatus.cancelled
                                      ? ShadcnButtonVariant.destructive
                                      : ShadcnButtonVariant.outline,
                                  onPressed: () => _updateStatus(status),
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF3B82F6);
      case BookingStatus.inProgress:
        return AppTheme.primary;
      case BookingStatus.readyForDelivery:
        return const Color(0xFF10B981);
      case BookingStatus.completed:
        return const Color(0xFF059669);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
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
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mutedForeground),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.foreground,
            ),
          ),
        ),
      ],
    );
  }
}
