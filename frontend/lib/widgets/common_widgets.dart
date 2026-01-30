import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Shadcn-style Button component
class ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final IconData? icon;
  final double? width;

  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive
        ? AppTheme.destructive
        : (isOutlined ? Colors.transparent : AppTheme.primary);
    final fgColor = isDestructive
        ? AppTheme.destructiveForeground
        : (isOutlined ? AppTheme.foreground : AppTheme.primaryForeground);
    final borderColor = isOutlined ? AppTheme.input : Colors.transparent;

    return SizedBox(
      width: width,
      height: 44,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }
}

/// Shadcn-style Input field
class ShadcnInput extends StatelessWidget {
  final TextEditingController controller;
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
    required this.controller,
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

/// Shadcn-style Card
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

/// Shadcn-style Accordion (ExpansionTile wrapper)
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

/// Shadcn-style Badge/Chip
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

/// Status Badge with auto-coloring
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Empty state widget
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

/// Service Card - Accordion style
class ServiceAccordionCard extends StatelessWidget {
  final String name;
  final String? description;
  final double price;
  final String estimatedTime;
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
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
              const Divider(height: 1),
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

/// Booking Accordion Card
class BookingAccordionCard extends StatelessWidget {
  final String bookingId;
  final String customerName;
  final DateTime bookingDate;
  final String status;
  final double totalPrice;
  final List<String> services;
  final VoidCallback? onTap;

  const BookingAccordionCard({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.bookingDate,
    required this.status,
    required this.totalPrice,
    required this.services,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShadcnAccordion(
      title: customerName,
      subtitle: '#${bookingId.substring(0, 8)} • ${bookingDate.day}/${bookingDate.month}/${bookingDate.year}',
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
            onPressed: onTap,
            width: double.infinity,
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}

/// Snackbar helper
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
