import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/service_provider.dart';
import '../../widgets/common_widgets.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices(activeOnly: false);
    });
  }

  void _showServiceDialog({String? serviceId}) {
    final serviceProvider = context.read<ServiceProvider>();
    final service = serviceId != null
        ? serviceProvider.services.firstWhere((s) => s.id == serviceId)
        : null;

    final nameController = TextEditingController(text: service?.name);
    final descriptionController = TextEditingController(text: service?.description);
    final priceController = TextEditingController(
      text: service?.price.toStringAsFixed(2),
    );
    final timeController = TextEditingController(
      text: service?.estimatedTime.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  service == null ? 'Add New Service' : 'Edit Service',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service == null
                      ? 'Create a new service for your customers'
                      : 'Update the service details',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 24),
                ShadcnInput(
                  controller: nameController,
                  label: 'Service Name',
                  placeholder: 'e.g., Oil Change',
                  prefixIcon: Icons.build_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadcnInput(
                  controller: descriptionController,
                  label: 'Description',
                  placeholder: 'Describe the service...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ShadcnInput(
                        controller: priceController,
                        label: 'Price (\$)',
                        placeholder: '0.00',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ShadcnInput(
                        controller: timeController,
                        label: 'Time (min)',
                        placeholder: '30',
                        prefixIcon: Icons.access_time,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter time';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ShadcnButton(
                  text: service == null ? 'Add Service' : 'Update Service',
                  width: double.infinity,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    bool success;
                    if (service == null) {
                      success = await serviceProvider.createService(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        estimatedTime: int.parse(timeController.text),
                      );
                    } else {
                      success = await serviceProvider.updateService(
                        id: service.id,
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        estimatedTime: int.parse(timeController.text),
                      );
                    }

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      showSuccessSnackbar(
                        context,
                        service == null
                            ? 'Service added successfully'
                            : 'Service updated successfully',
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String serviceId, String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Delete Service',
          style: TextStyle(
            color: AppTheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$serviceName"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.mutedForeground),
        ),
        actions: [
          ShadcnButton(
            text: 'Cancel',
            variant: ShadcnButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
          ShadcnButton(
            text: 'Delete',
            variant: ShadcnButtonVariant.destructive,
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ServiceProvider>().deleteService(serviceId);
              if (success && mounted) {
                showSuccessSnackbar(context, 'Service deleted');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Manage Services',
          style: TextStyle(
            color: AppTheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ShadcnButton(
              text: 'Add',
              icon: Icons.add,
              size: ShadcnButtonSize.sm,
              onPressed: () => _showServiceDialog(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => serviceProvider.loadServices(activeOnly: false),
        color: AppTheme.primary,
        child: serviceProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              )
            : serviceProvider.services.isEmpty
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
                            Icons.build_outlined,
                            size: 32,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No services yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first service to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ShadcnButton(
                          text: 'Add Service',
                          icon: Icons.add,
                          onPressed: () => _showServiceDialog(),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: serviceProvider.services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final service = serviceProvider.services[index];
                      return ServiceAccordionCard(
                        name: service.name,
                        description: service.description,
                        price: service.price,
                        estimatedTime: service.estimatedTimeDisplay,
                        isActive: service.isActive,
                        showActions: true,
                        onEdit: () => _showServiceDialog(serviceId: service.id),
                        onDelete: () => _confirmDelete(service.id, service.name),
                      );
                    },
                  ),
      ),
    );
  }
}
