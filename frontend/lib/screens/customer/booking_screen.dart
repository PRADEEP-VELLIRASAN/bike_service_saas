import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';

class BookingScreen extends StatefulWidget {
  final List<String> selectedServiceIds;

  const BookingScreen({super.key, required this.selectedServiceIds});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: AppTheme.primaryForeground,
              surface: AppTheme.card,
              onSurface: AppTheme.foreground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final bookingProvider = context.read<BookingProvider>();
    
    final success = await bookingProvider.createBooking(
      serviceIds: widget.selectedServiceIds,
      bookingDate: _selectedDate,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (success && mounted) {
      showSuccessSnackbar(context, 'Booking confirmed! Check your email for confirmation.');
      Navigator.pop(context, true);
    } else if (mounted && bookingProvider.error != null) {
      showErrorSnackbar(context, bookingProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final selectedServices = serviceProvider.services
        .where((s) => widget.selectedServiceIds.contains(s.id))
        .toList();

    final totalPrice = selectedServices.fold(0.0, (sum, s) => sum + s.price);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Confirm Booking',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                const Text(
                  'Booking Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: ShadcnCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Appointment Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppTheme.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Services
                const Text(
                  'Selected Services',
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
                      ...selectedServices.asMap().entries.map(
                        (entry) => Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.value.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          entry.value.estimatedTimeDisplay,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${entry.value.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (entry.key < selectedServices.length - 1)
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
                            '\$${totalPrice.toStringAsFixed(2)}',
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
                const SizedBox(height: 24),

                // Notes
                const Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                ShadcnInput(
                  controller: _notesController,
                  placeholder: 'Any special requests or notes for the service...',
                  maxLines: 3,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SafeArea(
                top: false,
                child: ShadcnButton(
                  text: 'Confirm Booking',
                  icon: Icons.check,
                  width: double.infinity,
                  isLoading: bookingProvider.isLoading,
                  onPressed: _confirmBooking,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
