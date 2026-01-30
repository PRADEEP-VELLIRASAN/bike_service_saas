import 'package:flutter/material.dart';
import '../config/theme.dart';

// ============================================================================
// SHADCN-STYLE BUTTON VARIANTS
// ============================================================================

enum ShadcnButtonVariant { primary, outline, ghost, destructive }
enum ShadcnButtonSize { sm, md, lg, icon }

/// Shadcn-style Button component
class ShadcnButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  // Legacy support
  final bool isOutlined;
  final bool isDestructive;

  const ShadcnButton({
    super.key,
    this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.variant = ShadcnButtonVariant.primary,
    this.size = ShadcnButtonSize.md,
    this.isOutlined = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve variant from legacy props if needed
    final resolvedVariant = isDestructive
        ? ShadcnButtonVariant.destructive
        : (isOutlined ? ShadcnButtonVariant.outline : variant);

    Color bgColor, fgColor, borderColor;
    switch (resolvedVariant) {
      case ShadcnButtonVariant.destructive:
        bgColor = AppTheme.destructive;
        fgColor = AppTheme.destructiveForeground;
        borderColor = Colors.transparent;
        break;
      case ShadcnButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppTheme.foreground;
        borderColor = AppTheme.input;
        break;
      case ShadcnButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppTheme.foreground;
        borderColor = Colors.transparent;
        break;
      case ShadcnButtonVariant.primary:
      default:
        bgColor = AppTheme.primary;
        fgColor = AppTheme.primaryForeground;
        borderColor = Colors.transparent;
    }

    double height;
    EdgeInsets padding;
    switch (size) {
      case ShadcnButtonSize.sm:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case ShadcnButtonSize.lg:
        height = 52;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
      case ShadcnButtonSize.icon:
        height = 40;
        padding = EdgeInsets.zero;
        break;
      case ShadcnButtonSize.md:
      default:
        height = 44;
        padding = const EdgeInsets.symmetric(horizontal: 16);
    }

    return SizedBox(
      width: size == ShadcnButtonSize.icon ? height : width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : size == ShadcnButtonSize.icon
                ? Icon(icon, size: 20)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        if (text != null) const SizedBox(width: 8),
                      ],
                      if (text != null)
                        Text(text!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
      ),
    );
  }
}

// ============================================================================
// SHADCN-STYLE INPUT
// ============================================================================

class ShadcnInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const ShadcnInput({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.foreground,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppTheme.mutedForeground)
                : null,
            suffixIcon: suffix,
            isDense: true,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SHADCN-STYLE CARD
// ============================================================================

class ShadcnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ShadcnCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      ),
    );
  }
}

// ============================================================================
// SHADCN-STYLE ACCORDION
// ============================================================================

class ShadcnAccordion extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final bool initiallyExpanded;
  final IconData? leadingIcon;

  const ShadcnAccordion({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.initiallyExpanded = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: leadingIcon != null
              ? Icon(leadingIcon, size: 20, color: AppTheme.mutedForeground)
              : null,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.foreground,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          children: [content],
        ),
      ),
    );
  }
}

// ============================================================================
// BADGES
// ============================================================================

class ShadcnBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final bool outline;

  const ShadcnBadge({
    super.key,
    required this.text,
    this.color,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = outline
        ? Colors.transparent
        : (color ?? AppTheme.secondary);
    final textColor = outline
        ? (color ?? AppTheme.foreground)
        : (color != null ? Colors.white : AppTheme.foreground);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(outline ? 0 : 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: outline ? (color ?? AppTheme.border) : Colors.transparent,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? textColor,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({super.key, required this.status, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppTheme.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: resolvedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: resolvedColor,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppTheme.mutedForeground),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SERVICE ACCORDION CARD
// ============================================================================

class ServiceAccordionCard extends StatelessWidget {
  final String name;
  final String? description;
  final double price;
  final String estimatedTime;
  final bool isActive;
  final bool isSelected;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ServiceAccordionCard({
    super.key,
    required this.name,
    this.description,
    required this.price,
    required this.estimatedTime,
    this.isActive = true,
    this.isSelected = false,
    this.showActions = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withOpacity(0.05) : AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.foreground,
                              ),
                            ),
                          ),
                          if (!isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Inactive',
                                style: TextStyle(fontSize: 10, color: AppTheme.mutedForeground),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: AppTheme.mutedForeground),
                          const SizedBox(width: 4),
                          Text(
                            estimatedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  )
                else
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.mutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.mutedForeground,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.destructive,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (isSelected) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BOOKING ACCORDION CARD
// ============================================================================

class BookingAccordionCard extends StatelessWidget {
  final String bookingId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final DateTime bookingDate;
  final String status;
  final double totalPrice;
  final List<String> services;
  final bool showCustomerInfo;
  final VoidCallback? onViewDetails;

  const BookingAccordionCard({
    super.key,
    required this.bookingId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.bookingDate,
    required this.status,
    required this.totalPrice,
    required this.services,
    this.showCustomerInfo = true,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ShadcnAccordion(
      title: showCustomerInfo ? customerName : 'Booking #${bookingId.substring(0, 8)}',
      subtitle: showCustomerInfo 
          ? '#${bookingId.substring(0, 8)} • ${bookingDate.day}/${bookingDate.month}/${bookingDate.year}'
          : '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}',
      leadingIcon: Icons.calendar_today_outlined,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status', style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
              StatusBadge(status: status),
            ],
          ),
          if (showCustomerInfo && customerEmail != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: AppTheme.mutedForeground),
                const SizedBox(width: 8),
                Text(customerEmail!, style: const TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
              ],
            ),
          ],
          if (showCustomerInfo && customerPhone != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppTheme.mutedForeground),
                const SizedBox(width: 8),
                Text(customerPhone!, style: const TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Text('Services', style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: services.map((s) => ShadcnBadge(text: s)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ShadcnButton(
            text: 'View Details',
            onPressed: onViewDetails,
            width: double.infinity,
            variant: ShadcnButtonVariant.outline,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SNACKBAR HELPERS
// ============================================================================

void showSnackbar(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
  final color = isError
      ? AppTheme.destructive
      : (isSuccess ? AppTheme.success : AppTheme.foreground);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (isError) ...[
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
          ] else if (isSuccess) ...[
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  showSnackbar(context, message, isSuccess: true);
}

void showErrorSnackbar(BuildContext context, String message) {
  showSnackbar(context, message, isError: true);
}

// ============================================================================
// LEGACY WIDGETS (for backwards compatibility)
// ============================================================================

// Legacy widgets that may still be referenced
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppTheme.background.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

// Legacy card types for backwards compatibility
class ServiceCard extends ServiceAccordionCard {
  const ServiceCard({
    super.key,
    required super.name,
    super.description,
    required super.price,
    required super.estimatedTime,
    super.isSelected,
    super.showActions,
    super.onTap,
    super.onEdit,
    super.onDelete,
  });
}

class BookingCard extends BookingAccordionCard {
  const BookingCard({
    super.key,
    required super.bookingId,
    required super.customerName,
    super.customerEmail,
    super.customerPhone,
    required super.bookingDate,
    required super.status,
    required super.totalPrice,
    required super.services,
    VoidCallback? onTap,
  }) : super(onViewDetails: onTap);
}

// Legacy text field
class CustomTextField extends ShadcnInput {
  const CustomTextField({
    super.key,
    super.controller,
    super.label,
    String? hint,
    super.prefixIcon,
    super.suffix,
    super.obscureText,
    super.keyboardType,
    super.validator,
    super.maxLines,
  }) : super(placeholder: hint);
}

// Legacy button
class GradientButton extends ShadcnButton {
  const GradientButton({
    super.key,
    required String text,
    super.onPressed,
    super.isLoading,
    super.width,
  }) : super(text: text);
}

// Legacy status chip
class StatusChip extends StatusBadge {
  const StatusChip({super.key, required super.status});
}
