import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';

class BookingStatusScreen extends StatefulWidget {
  final String bookingId;

  const BookingStatusScreen({super.key, required this.bookingId});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().getBooking(widget.bookingId);
    });
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
          'Booking Status',
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
                      // Status Progress
                      _StatusProgress(status: booking.status),
                      const SizedBox(height: 32),

                      // Booking Info Card
                      const Text(
                        'Booking Details',
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
                              label: 'Booking ID',
                              value: '#${booking.id.substring(0, 8).toUpperCase()}',
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            _InfoRow(
                              label: 'Booking Date',
                              value: '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                            ),
                            const Divider(color: AppTheme.border, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                                StatusBadge(
                                  status: booking.statusDisplay,
                                  color: _getStatusColor(booking.status),
                                ),
                              ],
                            ),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ShadcnCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            booking.notes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ),
                      ],

                      // Cancel Button
                      if (booking.status == BookingStatus.pending ||
                          booking.status == BookingStatus.confirmed) ...[
                        const SizedBox(height: 32),
                        ShadcnButton(
                          text: 'Cancel Booking',
                          variant: ShadcnButtonVariant.destructive,
                          width: double.infinity,
                          onPressed: () => _showCancelDialog(context),
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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: AppTheme.foreground),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: AppTheme.mutedForeground),
        ),
        actions: [
          ShadcnButton(
            text: 'No',
            variant: ShadcnButtonVariant.outline,
            onPressed: () => Navigator.pop(ctx),
          ),
          ShadcnButton(
            text: 'Yes, Cancel',
            variant: ShadcnButtonVariant.destructive,
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<BookingProvider>()
                  .cancelBooking(widget.bookingId);
              if (success && mounted) {
                Navigator.pop(context);
                showSuccessSnackbar(context, 'Booking cancelled');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.mutedForeground,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.foreground,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _StatusProgress extends StatelessWidget {
  final BookingStatus status;

  const _StatusProgress({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.pending_actions, label: 'Pending', status: BookingStatus.pending),
      (icon: Icons.check_circle_outline, label: 'Confirmed', status: BookingStatus.confirmed),
      (icon: Icons.build, label: 'In Progress', status: BookingStatus.inProgress),
      (icon: Icons.local_shipping, label: 'Ready', status: BookingStatus.readyForDelivery),
      (icon: Icons.check_circle, label: 'Completed', status: BookingStatus.completed),
    ];

    int currentIndex = steps.indexWhere((s) => s.status == status);
    if (currentIndex == -1) currentIndex = 0;

    return ShadcnCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index <= currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == steps.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.primary
                                  : AppTheme.muted,
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(color: AppTheme.primary, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              steps[index].icon,
                              color: isActive ? AppTheme.primaryForeground : AppTheme.mutedForeground,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            steps[index].label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              color: isActive
                                  ? AppTheme.foreground
                                  : AppTheme.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: index < currentIndex
                                ? AppTheme.primary
                                : AppTheme.border,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
